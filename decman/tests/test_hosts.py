"""Read-only host composition checks; requires the installed decman package.

Run: python -m unittest discover -s decman/tests -v
Each host is imported in a fresh process to isolate decman's global state.
No source.py, lifecycle hooks, package-manager commands or services are run.
"""

import json
from pathlib import Path
import subprocess
import sys
import unittest


DECMAN_ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = """
import importlib
import json
import sys
from unittest.mock import patch

import decman
from decman.plugins import run_methods_with_attribute

host, repo = sys.argv[1:]
with (
    patch('modules.common.archlinux.has_repo', side_effect=lambda name: name == repo),
    patch('decman.prg', side_effect=AssertionError('must not run commands')),
    patch('subprocess.Popen', side_effect=AssertionError('must not launch processes')),
):
    importlib.import_module('hosts.' + host)
    assert decman.pacman is not None
    assert decman.aur is not None
    packages = set(decman.pacman.packages)
    aur_packages = set(decman.aur.packages)
    units = set()
    user_units = set()
    for mod in decman.modules:
        for declared in run_methods_with_attribute(mod, '__pacman__packages__'):
            packages.update(declared)
        for declared in run_methods_with_attribute(mod, '__aur__packages__'):
            aur_packages.update(declared)
        for declared in run_methods_with_attribute(mod, '__systemd__units__'):
            units.update(declared)
        for declared in run_methods_with_attribute(mod, '__systemd__user__units__'):
            for names in declared.values():
                user_units.update(names)
    from modules.gui.games import GamesModule
    from modules.work.work import WorkModule
    print(json.dumps({
        'modules': [mod.name for mod in decman.modules],
        'packages': sorted(packages),
        'aur_packages': sorted(aur_packages),
        'units': sorted(units),
        'user_units': sorted(user_units),
        'game_files': [path for mod in decman.modules
                       if isinstance(mod, GamesModule) for path in mod.files()],
        'work_files': {path: file.content for mod in decman.modules
                       if isinstance(mod, WorkModule) for path, file in mod.files().items()},
        'upgrade': decman.pacman.commands.upgrade(),
    }))
"""


def snapshot(host, repo, root=DECMAN_ROOT):
    result = subprocess.run(
        [sys.executable, '-c', SNAPSHOT, host, repo],
        cwd=root,
        capture_output=True,
        text=True,
    )
    if result.returncode:
        raise AssertionError(f'{host} snapshot failed:\n{result.stderr}')
    return json.loads(result.stdout)


class HostCompositionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ada = snapshot('ada', 'endeavouros')
        cls.titan = snapshot('titan', 'cachyos')
        cls.xen = snapshot('xen', 'endeavouros')

    def test_ada_preserves_shared_desktop_and_work_modules(self):
        titan_only = {'games', 'host_mkinitcpio', 'host_cachyos', 'titan_services'}
        expected = (set(self.titan['modules']) - titan_only) | {
            'host_arch_kernel', 'host_dracut', 'endeavouros',
        }
        self.assertEqual(set(self.ada['modules']), expected)
        self.assertEqual(len(self.ada['modules']), len(expected))
        self.assertEqual(self.ada['work_files'], self.titan['work_files'])
        self.assertEqual(self.ada['work_files'], {
            '/etc/environment.d/50-teleport.conf': 'TELEPORT_TOOLS_VERSION=off\n',
        })

    def test_ada_kernel_and_gpu_stack(self):
        packages = set(self.ada['packages'])
        self.assertTrue({
            'linux', 'linux-headers', 'linux-lts', 'linux-lts-headers',
            'dracut', 'kernel-install-for-dracut', 'endeavouros-keyring',
            'intel-ucode', 'nvidia-open-dkms', 'nvidia-utils',
            'opencl-nvidia', 'libva-nvidia-driver', 'openrgb',
        } <= packages)
        self.assertFalse({'mkinitcpio', 'limine', 'linux-cachyos'} & packages)
        self.assertFalse(any(package.startswith('lib32-') for package in packages))

    def test_ada_has_work_and_non_gaming_remote_tools(self):
        self.assertTrue({
            'aws-cli', 'azure-cli', 'terraform', 'terragrunt',
        } <= set(self.ada['packages']))
        self.assertTrue({
            'cursor-bin', 'slack-desktop', 'teams-for-linux-bin',
            'teleport-bin', 'vault-bin', 'dcvviewer-bin',
            'globalprotect-openconnect-git', 'rustdesk-bin', 'parsec-bin',
        } <= set(self.ada['aur_packages']))
        self.assertNotIn('cursor-bin', self.ada['packages'])

    def test_ada_omits_gaming_and_titan_only_services(self):
        packages = set(self.ada['packages']) | set(self.ada['aur_packages'])
        self.assertFalse({
            'steam', 'heroic-games-launcher-bin', 'moonlight-qt',
            'virtualhere-client', 'virtualhere-client-bin',
            'virtualhere-server-bin', 'lib32-extest', 'sunshine', 'icu76',
            'gamescope-git', 'lib32-gamescope-plus', 'scopebuddy',
            'apcupsd', 'rustdesk-server-bin',
        } & packages)
        self.assertFalse({'virtualhere.service', 'apcupsd.service'} & set(self.ada['units']))
        self.assertNotIn('sunshine.service', self.ada['user_units'])
        self.assertEqual(self.ada['game_files'], [])
        self.assertNotIn('--ignore', self.ada['upgrade'])

    def test_existing_gaming_hosts_still_opt_in(self):
        for host in (self.titan, self.xen):
            with self.subTest(modules=host['modules']):
                self.assertEqual(host['modules'].count('games'), 1)
                self.assertTrue({'steam', 'moonlight-qt'} <= set(host['packages']))
                self.assertIn('virtualhere-server-bin', host['aur_packages'])
                self.assertEqual(host['game_files'], [
                    '/etc/firewalld/services/steam-remote-play.xml',
                ])
        self.assertIn('lib32-nvidia-utils', self.titan['packages'])
        self.assertIn('sunshine.service', self.titan['user_units'])
        self.assertEqual(self.titan['upgrade'][-2:], ['--ignore', 'lib32-gamescope'])


if __name__ == '__main__':
    unittest.main()
