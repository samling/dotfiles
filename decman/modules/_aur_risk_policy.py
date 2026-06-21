import dataclasses
import time
import urllib.parse

import requests
from decman.core import output
from decman.plugins.aur.error import ForeignPackageManagerError
from decman.plugins.aur.fpm import ForeignPackageManager


_MAINTAINERS_KEY = "aur_known_maintainers"
_DEFAULT_RECENT_WINDOW_SECONDS = 3 * 24 * 60 * 60


class AurRiskPolicyError(Exception):
    pass


@dataclasses.dataclass(frozen=True, slots=True)
class AurMetadata:
    name: str
    package_base: str
    maintainer: str | None
    last_modified: int | None

    @classmethod
    def from_rpc_result(cls, result: dict) -> "AurMetadata":
        return cls(
            name=result["Name"],
            package_base=result["PackageBase"],
            maintainer=result.get("Maintainer"),
            last_modified=result.get("LastModified"),
        )


def install(recent_window_seconds: int = _DEFAULT_RECENT_WINDOW_SECONDS) -> None:
    original = ForeignPackageManager.resolve_dependencies
    if getattr(original, "__aur_risk_policy_wrapped__", False):
        return

    def wrapped(self, foreign_pkgs, foreign_dep_pkgs=None):
        result = original(self, foreign_pkgs, foreign_dep_pkgs)
        package_names = (
            set(result.foreign_pkgs)
            | set(result.foreign_dep_pkgs)
            | set(result.foreign_build_dep_pkgs)
        )
        try:
            enforce_package_policy(
                package_names,
                self._store,
                recent_window_seconds=recent_window_seconds,
            )
        except AurRiskPolicyError as error:
            raise ForeignPackageManagerError(str(error)) from error
        return result

    wrapped.__aur_risk_policy_wrapped__ = True
    ForeignPackageManager.resolve_dependencies = wrapped


def enforce_package_policy(
    package_names: set[str],
    store,
    recent_window_seconds: int = _DEFAULT_RECENT_WINDOW_SECONDS,
) -> None:
    if not package_names:
        return

    evaluate_package_risks(
        package_names,
        store,
        metadata_by_package=fetch_aur_metadata(package_names),
        now=int(time.time()),
        recent_window_seconds=recent_window_seconds,
    )


def evaluate_package_risks(
    package_names: set[str],
    store,
    metadata_by_package: dict[str, AurMetadata],
    now: int,
    recent_window_seconds: int,
) -> None:
    store.ensure(_MAINTAINERS_KEY, {})
    known_maintainers = store[_MAINTAINERS_KEY]
    maintainer_updates: dict[str, str | None] = {}
    risk_messages: list[str] = []
    recent_cutoff = now - recent_window_seconds

    for package_name in sorted(package_names):
        metadata = metadata_by_package.get(package_name)
        if metadata is None:
            output.print_debug(f"No AUR metadata for {package_name}; skipping risk checks.")
            continue

        if metadata.last_modified is not None and metadata.last_modified >= recent_cutoff:
            risk_messages.append(
                f"{package_name}: modified {_format_duration(now - metadata.last_modified)} ago "
                f"(inside {_format_duration(recent_window_seconds)} review window)"
            )

        if package_name not in known_maintainers:
            maintainer_updates[package_name] = metadata.maintainer
        elif known_maintainers[package_name] != metadata.maintainer:
            risk_messages.append(
                f"{package_name}: maintainer changed from "
                f"{_maintainer_name(known_maintainers[package_name])} to "
                f"{_maintainer_name(metadata.maintainer)}"
            )

    if risk_messages:
        output.print_warning(
            "AUR package risk policy flagged package(s). Recent AUR changes are "
            "not automatically bad, but they deserve PKGBUILD review before build "
            "because compromised or transferred packages often change shortly "
            "before abuse."
        )
        output.print_list("AUR risk details:", risk_messages, elements_per_line=1)

    known_maintainers.update(maintainer_updates)


def fetch_aur_metadata(package_names: set[str], timeout: int = 30) -> dict[str, AurMetadata]:
    metadata: dict[str, AurMetadata] = {}
    packages = sorted(package_names)
    max_pkgs_per_request = 200

    for offset in range(0, len(packages), max_pkgs_per_request):
        batch = packages[offset : offset + max_pkgs_per_request]
        query = urllib.parse.urlencode([("arg[]", package) for package in batch])
        url = f"https://aur.archlinux.org/rpc/v5/info?{query}"
        output.print_debug(f"AUR risk metadata URL = {url}")
        try:
            response = requests.get(url, timeout=timeout)
            data = response.json()
        except Exception as error:
            raise AurRiskPolicyError("Failed to fetch AUR risk metadata.") from error

        if data.get("type") == "error":
            raise AurRiskPolicyError(f"AUR RPC returned error: {data.get('error')}")

        for result in data.get("results", []):
            item = AurMetadata.from_rpc_result(result)
            metadata[item.name] = item
            metadata.setdefault(item.package_base, item)

    return metadata


def _maintainer_name(maintainer: str | None) -> str:
    return maintainer or "<orphaned>"


def _format_duration(seconds: int) -> str:
    if seconds < 60:
        return _format_unit(seconds, "second")
    minutes = seconds // 60
    if minutes < 60:
        return _format_unit(minutes, "minute")
    hours = minutes // 60
    if hours < 24:
        return _format_unit(hours, "hour")
    days = hours // 24
    return _format_unit(days, "day")


def _format_unit(value: int, unit: str) -> str:
    suffix = "" if value == 1 else "s"
    return f"{value} {unit}{suffix}"
