"""AUR policy/cache regression tests with no network, builds or installs."""

import importlib
import os
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

from decman.core import command, output
from decman.core.store import Store
from decman.plugins.aur import fpm
from decman.plugins.aur.commands import AurCommands
from decman.plugins.aur.error import ForeignPackageManagerError
from decman.plugins.aur.resolver import ForeignPackage

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
aur_commands = importlib.import_module('modules._aur_commands')
install_cache = aur_commands.install_cache
prompts = importlib.import_module('modules._aur_prompts')
risk = importlib.import_module('modules._aur_risk_policy')


class AurPromptTests(unittest.TestCase):
    def test_only_package_prompts_are_suppressed_and_install_is_idempotent(self):
        with patch.object(output, 'prompt_confirm', return_value=False) as original:
            prompts.install()
            patched = output.prompt_confirm
            prompts.install()
            self.assertIs(output.prompt_confirm, patched)
            self.assertFalse(output.prompt_confirm('Review PKGBUILD or show diff for foo?', True))
            self.assertTrue(output.prompt_confirm('Build this package?', False))
            original.assert_not_called()
            self.assertFalse(output.prompt_confirm('Proceed?', True))
            self.assertFalse(output.prompt_confirm('Remove packages?', False))
            self.assertEqual(original.call_count, 2)

    def test_declining_batch_aborts_before_builds_or_dependency_installs(self):
        resolved = fpm.ResolvedDependencies()
        resolved.foreign_pkgs = {'foo'}
        manager = Mock(spec=fpm.ForeignPackageManager)
        manager.resolve_dependencies.return_value = resolved
        with (
            patch.object(output, 'prompt_confirm', return_value=False),
            patch.object(output, 'print_list'),
            patch.object(fpm, 'PackageBuilder') as builder,
        ):
            prompts.install()
            with self.assertRaisesRegex(ForeignPackageManagerError, 'aborted'):
                fpm.ForeignPackageManager.install(manager, ['foo'])
            builder.assert_not_called()
            manager.resolve_dependencies.assert_called_once_with(['foo'], [])


class AurRiskTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.store = Store(str(Path(temp.name) / 'state.json'))
        self.warning = self.enterContext(patch.object(output, 'print_warning'))
        self.details = self.enterContext(patch.object(output, 'print_list'))
        self.confirm = self.enterContext(patch.object(output, 'prompt_confirm', side_effect=AssertionError))

    def test_three_day_boundary_missing_custom_package_and_maintainer_changes(self):
        now = 1_000_000
        window = 3 * 24 * 60 * 60
        self.store['aur_known_maintainers'] = {'old': 'alice'}
        metadata = {
            name: risk.AurMetadata(name, name, maintainer, timestamp)
            for name, maintainer, timestamp in [
                ('recent', 'alice', now - 1),
                ('boundary', 'alice', now - window),
                ('old', 'bob', now - window - 1),
                ('unchanged', 'alice', now - window - 1),
            ]
        }
        risk.evaluate_package_risks(set(metadata) | {'custom'}, self.store, metadata, now, window)
        self.warning.assert_called_once()
        messages = '\n'.join(self.details.call_args.args[1])
        self.assertIn('recent: modified', messages)
        self.assertIn('boundary: modified', messages)
        self.assertIn('old: maintainer changed from alice to bob', messages)
        self.assertNotIn('old: modified', messages)
        self.assertNotIn('unchanged:', messages)
        self.assertNotIn('custom:', messages)
        self.assertEqual(self.store['aur_known_maintainers']['old'], 'bob')
        self.confirm.assert_not_called()

    def test_metadata_failure_warns_and_returns_resolved_batch(self):
        resolved = fpm.ResolvedDependencies()
        resolved.foreign_pkgs = {'foo'}
        with (
            patch.object(fpm.ForeignPackageManager, 'resolve_dependencies', return_value=resolved),
            patch.object(risk, 'fetch_aur_metadata', side_effect=risk.AurRiskPolicyError('offline')),
        ):
            risk.install()
            wrapped = fpm.ForeignPackageManager.resolve_dependencies
            risk.install()
            self.assertIs(wrapped, fpm.ForeignPackageManager.resolve_dependencies)
            manager = Mock(_store=self.store)
            self.assertIs(wrapped(manager, ['foo']), resolved)
            self.assertIn('continuing', self.warning.call_args.args[0])
            self.confirm.assert_not_called()

    def test_metadata_http_and_malformed_responses_are_policy_errors(self):
        for payload in (
            {'type': 'error', 'error': 'bad request'}, {}, [], {'results': [None]},
            {'results': [{'Name': 'foo', 'PackageBase': 'foo', 'LastModified': 'invalid'}]},
        ):
            with self.subTest(payload=payload), patch.object(risk.requests, 'get') as get:
                get.return_value.json.return_value = payload
                with self.assertRaises(risk.AurRiskPolicyError):
                    risk.fetch_aur_metadata({'foo'})
                get.return_value.raise_for_status.assert_called_once()


class AurCacheTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.store = Store(str(self.root / 'state.json'))
        self.enterContext(patch.object(fpm, 'add_package_to_cache', fpm.add_package_to_cache))
        self.enterContext(patch.object(fpm.PackageBuilder, '_are_all_pkgs_cached', fpm.PackageBuilder._are_all_pkgs_cached))
        self.enterContext(patch.object(output, 'print_info'))
        self.enterContext(patch.object(output, 'print_warning'))
        self.enterContext(patch.object(command, 'prg', side_effect=AssertionError('no real commands')))
        self.search = Mock()
        self.search.get_package_info.return_value = SimpleNamespace(version='1-1')
        self.builder = fpm.PackageBuilder(
            self.search, self.store, Mock(), fpm.ResolvedDependencies(),
            AurCommands(), str(self.root), str(self.root / 'build'), 'nobody',
        )

    def add_cached(self, name, version='1-1'):
        archive = self.root / f'{name}-{version}.pkg.tar.zst'
        archive.write_bytes(b'test archive')
        fpm.add_package_to_cache(self.store, name, version, str(archive))
        return archive

    def test_completed_build_persisted_before_later_failure_and_reused_after_reload(self):
        install_cache()
        self.addCleanup(os.chdir, os.getcwd())
        for name in ('successful', 'failed'):
            directory = self.root / name
            directory.mkdir()
            self.builder.pkgbase_dir_map[name] = str(directory)
        archive = self.root / 'successful' / 'successful-1-1.pkg.tar.zst'
        archive.write_bytes(b'built archive')

        def build_command(*args, **kwargs):
            if Path.cwd().name == 'failed':
                raise ForeignPackageManagerError('next build failed')
            return ''

        with (
            patch.object(command, 'prg', side_effect=build_command),
            patch.object(self.builder, '_get_chroot_packages', return_value=([], [])),
            patch.object(self.builder, '_find_pkgfile', return_value=str(archive)),
        ):
            self.builder.build_packages('successful', [ForeignPackage('successful')], force=False)
            with self.assertRaisesRegex(ForeignPackageManagerError, 'next build failed'):
                self.builder.build_packages('failed', [ForeignPackage('failed')], force=False)
        # No Store context exit/save: only our per-archive checkpoint persisted it.
        reloaded = Store(str(self.root / 'state.json'))
        self.assertIsNotNone(fpm.find_latest_cached_package(reloaded, 'successful'))
        self.assertIsNone(fpm.find_latest_cached_package(reloaded, 'failed'))
        self.builder._store = reloaded
        with patch.object(self.builder, '_get_chroot_packages', side_effect=AssertionError('must skip')):
            self.builder.build_packages('successful', [ForeignPackage('successful')], force=False)

    def test_normal_runs_rebuild_devel_but_resume_reuses_matching_cached_builds(self):
        install_cache()
        self.add_cached('foo-git')
        packages = [ForeignPackage('foo-git')]
        self.assertFalse(self.builder._are_all_pkgs_cached(packages))
        install_cache(resume=True)
        self.assertTrue(self.builder._are_all_pkgs_cached(packages))
        with patch.object(self.builder, '_get_chroot_packages', side_effect=RuntimeError('building')):
            self.builder.build_packages('foo-git', packages, force=False)
            with self.assertRaisesRegex(RuntimeError, 'building'):
                self.builder.build_packages('foo-git', packages, force=True)

    def test_resume_requires_every_split_output_and_matching_versions(self):
        install_cache(resume=True)
        first = self.add_cached('foo-git')
        packages = [ForeignPackage('foo-git'), ForeignPackage('foo-debug')]
        self.assertFalse(self.builder._are_all_pkgs_cached(packages))
        self.add_cached('foo-debug', version='0-1')
        self.assertFalse(self.builder._are_all_pkgs_cached(packages))
        self.search.get_package_info.side_effect = lambda name: SimpleNamespace(
            version='1-1' if name == 'foo-git' else '0-1',
        )
        self.assertTrue(self.builder._are_all_pkgs_cached(packages))
        first.unlink()
        self.assertFalse(self.builder._are_all_pkgs_cached(packages))

    def test_checkpoint_is_idempotent_and_dry_run_does_not_write_store(self):
        install_cache(resume=True)
        checkpoint = fpm.add_package_to_cache
        cached = fpm.PackageBuilder._are_all_pkgs_cached
        install_cache(resume=True)
        self.assertIs(fpm.add_package_to_cache, checkpoint)
        self.assertIs(fpm.PackageBuilder._are_all_pkgs_cached, cached)
        self.store = Store(str(self.root / 'dry-state.json'), dry_run=True)
        self.add_cached('foo')
        self.assertFalse((self.root / 'dry-state.json').exists())


if __name__ == '__main__':
    unittest.main()
