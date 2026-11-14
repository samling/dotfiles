"""Pane prompt correctness and zero-kubectl cache hits (no cluster access)."""

import os
import shutil
import subprocess
import sys
import tempfile
import tomllib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOOK = ROOT / "chezmoi/dot_zsh/kube-prompt.zsh"
CONFIG = ROOT / "chezmoi/dot_config/starship.toml"


@unittest.skipUnless(
    shutil.which("zsh") and shutil.which("kubectl"), "needs zsh and kubectl"
)
class KubePromptTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.global_config = self.directory / "global.yaml"
        self.pane = self.directory / "pane.yaml"
        self.global_config.write_text(
            "apiVersion: v1\nkind: Config\ncurrent-context: global\n"
        )
        self.pane.write_text("apiVersion: v1\nkind: Config\ncurrent-context: pane-a\n")
        binary = self.directory / "kubectl"
        binary.write_text(
            '#!/bin/sh\nprintf "call\\n" >> "$CALL_LOG"\n'
            'if [ "$1" = ctx ]; then\n'
            '  shift\n  exec "$REAL_KUBECTL" config use-context "$@"\nfi\n'
            'exec "$REAL_KUBECTL" "$@"\n'
        )
        binary.chmod(0o700)
        self.log = self.directory / "calls"
        self.env = dict(
            os.environ,
            PATH=f"{self.directory}:{os.environ['PATH']}",
            REAL_KUBECTL=shutil.which("kubectl") or "kubectl",
            CALL_LOG=str(self.log),
            KUBECONFIG_GLOBAL=str(self.global_config),
            KUBECONFIG=f"{self.pane}:{self.global_config}",
            PANE=str(self.pane),
            HOOK=str(HOOK),
        )

    def run_hook(self, script):
        result = subprocess.run(
            ["zsh", "-f", "-c", 'source "$HOOK" || exit; ' + script],
            env=self.env,
            text=True,
            capture_output=True,
            timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        return result.stdout.splitlines()

    def calls(self):
        return len(self.log.read_text().splitlines()) if self.log.exists() else 0

    def test_starship_displays_cached_environment_without_custom_command(self):
        config = tomllib.loads(CONFIG.read_text())
        self.assertNotIn("kube_pane", config.get("custom", {}))
        module = config["env_var"]["kube_pane"]
        self.assertEqual(module["variable"], "STARSHIP_KUBE_PANE_CONTEXT")
        self.assertIn("${env_var.kube_pane}", config["format"])

    def test_unchanged_prompts_reuse_both_lookups(self):
        self.assertEqual(
            self.run_hook("""
            repeat 10 { _kube-prompt-refresh; print -r -- "$STARSHIP_KUBE_PANE_CONTEXT" }
        """),
            ["pane-a"] * 10,
        )
        self.assertEqual(self.calls(), 2)

    def test_identical_paths_clear_inherited_indicator_without_lookups(self):
        self.env["STARSHIP_KUBE_PANE_CONTEXT"] = "stale"
        self.assertEqual(
            self.run_hook("""
            KUBECONFIG=$KUBECONFIG_GLOBAL
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
        """),
            ["unset"],
        )
        self.assertEqual(self.calls(), 0)

    def test_both_unset_skip_lookups(self):
        self.assertEqual(
            self.run_hook("""
            unset KUBECONFIG KUBECONFIG_GLOBAL
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
        """),
            ["unset"],
        )
        self.assertEqual(self.calls(), 0)

    def test_equal_contexts_with_different_paths_hide_indicator(self):
        self.pane.write_bytes(self.global_config.read_bytes())
        self.assertEqual(
            self.run_hook("""
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
        """),
            ["unset"],
        )
        self.assertEqual(self.calls(), 2)

    def test_same_size_nanosecond_edit_invalidates_cache(self):
        timestamp = 1_700_000_000_000_000_100
        os.utime(self.pane, ns=(timestamp, timestamp))
        self.env["TEST_PYTHON"] = sys.executable
        self.assertEqual(
            self.run_hook("""
            _kube-prompt-refresh
            print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
            print -r -- $'apiVersion: v1\\nkind: Config\\ncurrent-context: pane-b' > "$PANE"
            "$TEST_PYTHON" -c 'import os; t=1700000000000000200; os.utime(os.environ["PANE"], ns=(t,t))'
            _kube-prompt-refresh
            [[ "$_KUBE_PROMPT_SIGNATURE" == *1700000000.000000200* ]] || exit 1
            print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
        """),
            ["pane-a", "pane-b"],
        )
        self.assertEqual(self.calls(), 4)

    def test_global_edit_invalidates_cache(self):
        self.assertEqual(
            self.run_hook("""
            _kube-prompt-refresh
            print -r -- $'apiVersion: v1\\nkind: Config\\ncurrent-context: pane-a' > "$KUBECONFIG_GLOBAL"
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
        """),
            ["unset"],
        )
        self.assertEqual(self.calls(), 4)

    def test_reset_clears_indicator_and_reentering_pane_refreshes(self):
        self.assertEqual(
            self.run_hook("""
            _kube-prompt-refresh
            local_config=$KUBECONFIG
            KUBECONFIG=$KUBECONFIG_GLOBAL
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
            KUBECONFIG=$local_config
            _kube-prompt-refresh
            print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
        """),
            ["unset", "pane-a"],
        )
        self.assertEqual(self.calls(), 4)

    def test_manual_override_without_pane_marker(self):
        self.env.pop("KUBECONFIG_PANE", None)
        self.env["KUBECONFIG"] = str(self.pane)
        self.assertEqual(
            self.run_hook("""
            _kube-prompt-refresh
            print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
        """),
            ["pane-a"],
        )

    def test_missing_file_creation_invalidates_cache(self):
        self.pane.unlink()
        self.assertEqual(
            self.run_hook("""
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
            print -r -- $'apiVersion: v1\\nkind: Config\\ncurrent-context: pane-b' > "$PANE"
            _kube-prompt-refresh
            print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
        """),
            ["unset", "pane-b"],
        )
        self.assertEqual(self.calls(), 4)

    def test_invalid_config_is_quiet_and_failure_is_cached(self):
        self.pane.write_text("invalid: [\n")
        self.assertEqual(
            self.run_hook("""
            repeat 3 { _kube-prompt-refresh }
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
        """),
            ["unset"],
        )
        self.assertEqual(self.calls(), 1)

    def test_path_change_invalidates_cache(self):
        self.assertEqual(
            self.run_hook("""
            _kube-prompt-refresh
            KUBECONFIG=$KUBECONFIG_GLOBAL:$PANE
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
        """),
            ["unset"],
        )
        self.assertEqual(self.calls(), 4)

    def test_spaces_empty_entries_and_relative_paths(self):
        folder = self.directory / "with spaces"
        folder.mkdir()
        (folder / "config").write_bytes(self.pane.read_bytes())
        self.env["FOLDER"] = str(folder)
        self.assertEqual(
            self.run_hook("""
            cd "$FOLDER"
            KUBECONFIG=":config::${KUBECONFIG_GLOBAL}:"
            _kube-prompt-refresh
            print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
            cd /
            _kube-prompt-refresh
            print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
        """),
            ["pane-a", "unset"],
        )
        self.assertEqual(self.calls(), 4)

    def prepare_pane_commands(self):
        tsh = self.directory / "tsh"
        tsh.write_text(
            '#!/bin/sh\n[ "${TSH_STATUS:-0}" = 0 ] || exit "$TSH_STATUS"\n'
            'printf "apiVersion: v1\\nkind: Config\\ncurrent-context: %s\\n" '
            '"$3" > "$KUBECONFIG"\n'
        )
        tsh.chmod(0o700)
        return '''
            source "${HOOK:h}/functions.zsh"
            function _kube-pane-overlay() { print -r -- "$PANE"; }
        '''

    def test_tsh_login_refreshes_before_next_prompt_and_then_reuses_cache(self):
        global_before = self.global_config.read_bytes()
        self.assertEqual(
            self.run_hook(self.prepare_pane_commands() + '''
                _kube-prompt-refresh
                tsh-kube-pane pane-b >/dev/null
                print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
                _kube-prompt-refresh
                print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
            '''),
            ["pane-b", "pane-b"],
        )
        self.assertEqual(self.global_config.read_bytes(), global_before)
        self.assertEqual(self.calls(), 5)

    def test_failed_tsh_login_preserves_status_and_cached_context(self):
        self.env["TSH_STATUS"] = "7"
        self.assertEqual(
            self.run_hook(self.prepare_pane_commands() + '''
                _kube-prompt-refresh
                tsh-kube-pane pane-b >/dev/null
                print -rl -- "$?" "$STARSHIP_KUBE_PANE_CONTEXT"
            '''),
            ["7", "pane-a"],
        )
        self.assertEqual(self.calls(), 2)

    def test_kx_pane_refreshes_before_next_prompt(self):
        self.pane.write_text(
            "apiVersion: v1\nkind: Config\ncurrent-context: pane-a\n"
            "contexts:\n- name: pane-a\n  context: {}\n"
            "- name: pane-b\n  context: {}\n"
        )
        self.assertEqual(
            self.run_hook(self.prepare_pane_commands() + '''
                _kube-prompt-refresh
                kx-pane pane-b >/dev/null
                print -rl -- "$?" "$STARSHIP_KUBE_PANE_CONTEXT"
                _kube-prompt-refresh
            '''),
            ["0", "pane-b"],
        )
        self.assertEqual(self.calls(), 5)

    def test_kx_pane_preserves_failed_picker_status(self):
        self.assertEqual(
            self.run_hook(self.prepare_pane_commands() + '''
                _kube-prompt-refresh
                kx-pane nonexistent >/dev/null 2>/dev/null
                print -rl -- "$?" "$STARSHIP_KUBE_PANE_CONTEXT"
            '''),
            ["1", "pane-a"],
        )
        self.assertEqual(self.calls(), 3)

    def test_reset_clears_cached_indicator_before_next_prompt(self):
        self.assertEqual(
            self.run_hook(self.prepare_pane_commands() + '''
                _kube-prompt-refresh
                kube-reset >/dev/null
                print -r -- "${STARSHIP_KUBE_PANE_CONTEXT-unset}"
                _kube-prompt-refresh
            '''),
            ["unset"],
        )
        self.assertEqual(self.calls(), 3)

    def test_pane_login_still_works_without_prompt_hook(self):
        self.assertEqual(
            self.run_hook(self.prepare_pane_commands() + '''
                unfunction _kube-prompt-refresh
                tsh-kube-pane pane-b
            '''),
            ["Pane kube context: pane-b"],
        )

    def test_force_refresh_bypasses_unchanged_signature(self):
        self.assertEqual(
            self.run_hook('''
                _kube-prompt-refresh
                STARSHIP_KUBE_PANE_CONTEXT=stale
                _kube-prompt-refresh --force
                print -r -- "$STARSHIP_KUBE_PANE_CONTEXT"
                _kube-prompt-refresh
            '''),
            ["pane-a"],
        )
        self.assertEqual(self.calls(), 4)

    def test_hook_registration_is_idempotent(self):
        self.assertEqual(
            self.run_hook("""
            source "$HOOK"
            print -r -- "${#precmd_functions[@]}"
            print -r -- "$precmd_functions[1]"
        """),
            ["1", "_kube-prompt-refresh"],
        )


if __name__ == "__main__":
    unittest.main()
