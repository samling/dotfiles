import dataclasses
import fnmatch
import json
import os
import shutil

from decman import Plugin
from decman.plugins import run_methods_with_attribute
import decman.core.output as output
import decman.core.command as command


@dataclasses.dataclass(frozen=True, slots=True)
class GithubPackage:
    repo: str
    pattern: str | None = None


@dataclasses.dataclass(frozen=True, slots=True)
class GithubReleaseInfo:
    name: str
    tag_name: str
    is_latest: bool
    published_at: str


class GithubRelease(Plugin):
    NAME = "github_release"

    def __init__(self) -> None:
        self.packages: set[str | GithubPackage] = set()
        self.ignored_packages: set[str | GithubPackage] = set()
        self.commands = GithubCommands()

    def packages(fn):
        fn.__github_release_packages__ = True
        return fn

    def available(self) -> bool:
        return (
            os.getenv("GH_TOKEN") is not None or os.getenv("GITHUB_TOKEN") is not None
        ) and shutil.which("gh") is not None

    def process_modules(self, store, modules):
        store.ensure("github_release_packages_for_module", {})

        for mod in modules:
            store["github_release_packages_for_module"].setdefault(mod.name, set())

            packages = set().union(*run_methods_with_attribute(mod, "__github_release_packages__"))
            package_keys = {str(package) for package in packages}

            if store["github_release_packages_for_module"][mod.name] != package_keys:
                mod._changed = True
                output.print_debug(
                    f"Module '{mod.name}' set to changed due to modified github release packages."
                )

            self.packages |= packages

            store["github_release_packages_for_module"][mod.name] = package_keys

    def apply(self, store, dry_run = False, params = None):
        return super().apply(store, dry_run, params)


class GithubCommands:
    def list_releases(self, pkg: GithubPackage, as_user: bool, latest_only: bool = False) -> list[str]:
        cmd = [
            "gh",
            "release",
            "list",
            "--repo",
            pkg.repo,
            "--json",
            "name,tagName,isLatest,publishedAt",
        ]

        if latest_only:
            cmd += ["--limit", "1"]

        return cmd

    def release_assets(self, pkg: GithubPackage, tag: str, as_user: bool) -> list[str]:
        return [
            "gh",
            "release",
            "view",
            tag,
            "--repo",
            pkg.repo,
            "--json",
            "assets",
        ]

class GithubInterface:
    def __init__(self, commands: GithubCommands) -> None:
        self._commands = commands

    def list_releases(
        self,
        pkgs: set[str | GithubPackage],
        user: str | None = None,
        latest_only: bool = False,
    ) -> set[GithubReleaseInfo]:
        as_user = user is not None
        releases: set[GithubReleaseInfo] = set()

        for pkg in {self._normalize_package(pkg) for pkg in pkgs}:
            cmd = self._commands.list_releases(pkg=pkg, as_user=as_user, latest_only=latest_only)
            _, releases_text = command.check_run_result(
                cmd, command.run(cmd, user=user, mimic_login=as_user)
            )
            pkg_releases = self._parse_releases(releases_text)

            if pkg.pattern is None:
                releases |= pkg_releases
                continue

            releases |= {
                release
                for release in pkg_releases
                if self._release_has_matching_asset(release, pkg, user, as_user)
            }

        return releases

    def _release_has_matching_asset(
        self, release: GithubReleaseInfo, pkg: GithubPackage, user: str | None, as_user: bool
    ) -> bool:
        if pkg.pattern is None:
            return False

        cmd = self._commands.release_assets(pkg=pkg, tag=release.tag_name, as_user=as_user)
        _, assets_text = command.check_run_result(
            cmd, command.run(cmd, user=user, mimic_login=as_user)
        )
        return any(
            fnmatch.fnmatchcase(asset, pkg.pattern)
            for asset in self._parse_asset_names(assets_text)
        )

    @staticmethod
    def _normalize_package(pkg: str | GithubPackage) -> GithubPackage:
        if isinstance(pkg, GithubPackage):
            return pkg
        return GithubPackage(pkg)

    @staticmethod
    def _parse_releases(text: str) -> set[GithubReleaseInfo]:
        return {
            GithubReleaseInfo(
                name=release["name"],
                tag_name=release["tagName"],
                is_latest=release["isLatest"],
                published_at=release["publishedAt"],
            )
            for release in json.loads(text)
        }

    @staticmethod
    def _parse_asset_names(text: str) -> set[str]:
        return {asset["name"] for asset in json.loads(text)["assets"]}
