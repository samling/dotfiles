"""Exercise the CLI profile with real chezmoi rendering, without secrets or installs."""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PI_TARGETS = {
    ".pi/agent/settings.json",
    ".pi/agent/hermes-memory-config.json",
    ".pi/agent/extensions/powerline-footer/theme.json",
}


@unittest.skipUnless(shutil.which("chezmoi"), "needs chezmoi")
class CliProfileTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.config = self.home / "chezmoi.toml"
        self.config.write_text('[data]\nprofile = "cli"\n')

    def chezmoi(self, *args, source=ROOT):
        result = subprocess.run(
            [
                "chezmoi", "--config", str(self.config),
                "--source", str(source), "--destination", str(self.home),
                "--cache", str(self.home / "cache"),
                "--persistent-state", str(self.home / "state.boltdb"),
                "--refresh-externals=never", "--no-tty", *args,
            ],
            env=dict(os.environ, HOME=str(self.home), WSL_DISTRO_NAME=""),
            text=True, capture_output=True, timeout=30,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_cli_manages_shell_editor_git_tmux_and_pi(self):
        files = self.chezmoi("managed", "--include=files").splitlines()
        for target in (
            ".zshrc", ".zsh/path.zsh", ".zsh/plugins.zsh", ".gitconfig",
            ".ripgreprc", ".tmux.conf", ".config/nvim/init.lua",
            ".config/starship.toml", ".config/delta/themes/catppuccin/catppuccin.gitconfig",
            ".local/bin/tmux-resurrect-snapshot",
        ):
            with self.subTest(target=target):
                self.assertIn(target, files)
        self.assertEqual({path for path in files if path.startswith(".pi/")}, PI_TARGETS)

    def test_cli_never_manages_desktop_secrets_or_ssh(self):
        files = self.chezmoi("managed", "--include=files").splitlines()
        allowed = (
            ".zshrc", ".zsh/", ".gitconfig", ".ripgreprc", ".tmux.conf", ".tmux/",
            ".config/nvim/", ".config/starship.toml", ".config/delta/",
            ".config/lsd/", ".config/eza/", ".config/btop/", ".config/k9s/",
            ".config/gitmux.conf", ".config/tmux-palette/",
            ".local/bin/tmux-resurrect-snapshot",
        )
        self.assertTrue(files)
        self.assertEqual(
            [path for path in files if path not in PI_TARGETS and not path.startswith(allowed)],
            [],
        )
        self.assertNotIn(".config/nvim/.claude/settings.local.json", files)

    def test_cli_excludes_pi_state_even_if_present_in_source(self):
        source = self.home / "test-source"
        source.mkdir()
        shutil.copyfile(ROOT / "chezmoi/.chezmoiignore.tmpl", source / ".chezmoiignore.tmpl")
        for name in (
            "settings.json", "hermes-memory-config.json", "extensions/powerline-footer/theme.json",
            "private_auth.json", "models.json", "sessions/fixture.jsonl",
            "pi-hermes-memory/sessions.db", "extensions/powerline-footer/auth.json",
        ):
            fixture = source / "dot_pi/agent" / name
            fixture.parent.mkdir(parents=True, exist_ok=True)
            fixture.touch()
        files = self.chezmoi("managed", "--include=files", source=source).splitlines()
        self.assertEqual(set(files), PI_TARGETS)

    def test_default_profile_still_manages_desktop(self):
        self.config.write_text("")
        files = self.chezmoi("managed", "--include=files").splitlines()
        self.assertIn(".config/niri/config.kdl", files)
        self.assertIn(".zshrc", files)


@unittest.skipUnless(shutil.which("zsh"), "needs zsh")
class PortableShellTests(unittest.TestCase):
    def test_cuda_override_is_preserved_and_on_path(self):
        result = subprocess.run(
            ["zsh", "-f", "-c", 'source "$ENV_FILE"; print -r -- "$CUDA_HOME"; print -r -- "$PATH"'],
            env=dict(os.environ, CUDA_HOME="/test/cuda", ENV_FILE=str(ROOT / "chezmoi/dot_zsh/env.zsh")),
            text=True, capture_output=True, timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        lines = result.stdout.splitlines()
        self.assertIn("/test/cuda", lines)
        self.assertIn("/test/cuda/bin", lines[-1].split(":"))

    @unittest.skipUnless(os.uname().sysname == "Linux", "Linux-only flags")
    def test_linux_does_not_set_macos_archflags(self):
        env = dict(os.environ, ENV_FILE=str(ROOT / "chezmoi/dot_zsh/env.zsh"))
        env.pop("ARCHFLAGS", None)
        result = subprocess.run(
            ["zsh", "-f", "-c", 'source "$ENV_FILE"; [[ -z ${ARCHFLAGS+x} ]]'],
            env=env, text=True, capture_output=True, timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)


@unittest.skipUnless(shutil.which("tmux"), "needs tmux")
class PortableTmuxTests(unittest.TestCase):
    def test_config_loads_and_ssh_copy_does_not_require_wayland(self):
        with tempfile.TemporaryDirectory() as directory:
            socket = str(Path(directory) / "tmux.sock")
            env = dict(os.environ, HOME=directory, SHELL="/bin/sh")
            env.pop("WAYLAND_DISPLAY", None)
            env.pop("TMUX", None)
            env.pop("TMUX_PANE", None)

            def tmux(*args):
                return subprocess.run(
                    ["tmux", "-S", socket, *args], env=env,
                    text=True, capture_output=True, timeout=15,
                )

            try:
                started = tmux("-f", "/dev/null", "new-session", "-d", "-s", "test")
                self.assertEqual(started.returncode, 0, started.stderr)
                loaded = tmux("source-file", str(ROOT / "chezmoi/dot_tmux.conf"))
                self.assertEqual(loaded.returncode, 0, loaded.stderr)
                binding = tmux("list-keys", "-T", "copy-mode-vi", "y")
                self.assertEqual(binding.returncode, 0, binding.stderr)
                self.assertIn("copy-selection-and-cancel", binding.stdout)
                self.assertNotIn("wl-copy", binding.stdout)
            finally:
                tmux("kill-server")


if __name__ == "__main__":
    unittest.main()
