#!/usr/bin/env python3
import argparse
import runpy
import subprocess
import sys
from pathlib import Path
from typing import Callable, Iterable, Sequence


def find_declared_asdeps(
    declared: Iterable[str],
    dep_installed: Iterable[str],
) -> list[str]:
    return sorted(set(declared) & set(dep_installed))


def declared_package_names(
    *,
    pacman_packages: Iterable[str],
    aur_packages: Iterable[str],
    custom_packages: Iterable[object],
) -> set[str]:
    return (
        set(pacman_packages)
        | set(aur_packages)
        | {package.pkgname for package in custom_packages}
    )


def run_preflight(
    *,
    declared: Iterable[str],
    dep_installed: Iterable[str],
    dry_run: bool,
    confirm: Callable[[str], bool],
    run: Callable[[Sequence[str]], subprocess.CompletedProcess],
) -> int:
    packages = find_declared_asdeps(declared, dep_installed)
    if not packages:
        return 0

    print("Packages declared in decman but currently marked as dependencies:")
    for package in packages:
        print(f"  {package}")

    cmd = ["sudo", "pacman", "-D", "--asexplicit", *packages]
    print()
    print("To prevent decman/pacman from treating them as orphanable, run:")
    print("  " + " ".join(cmd))

    if dry_run:
        return 1

    if not confirm("Mark these packages explicit before running decman? [y/N] "):
        return 1

    run(cmd)
    return 0


def load_declared_pacman_packages(source: Path) -> set[str]:
    source = source.resolve()
    sys.path.insert(0, str(source.parent))
    namespace = runpy.run_path(str(source))
    decman = namespace["decman"]

    from decman.plugins import run_methods_with_attribute

    aur_packages = set(decman.aur.packages)
    custom_packages = set(decman.aur.custom_packages)
    for mod in decman.modules:
        aur_packages |= set().union(
            *run_methods_with_attribute(mod, "__aur__packages__")
        )
        custom_packages |= set().union(
            *run_methods_with_attribute(mod, "__custom__packages__")
        )

    return declared_package_names(
        pacman_packages=namespace["_declared"],
        aur_packages=aur_packages,
        custom_packages=custom_packages,
    )


def load_dep_installed_packages() -> set[str]:
    result = subprocess.run(
        ["pacman", "-Qdq"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return set(result.stdout.splitlines())


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Find decman-declared pacman packages still marked --asdeps.",
    )
    parser.add_argument(
        "--source",
        type=Path,
        default=Path(__file__).with_name("source.py"),
        help="Path to decman source.py.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Report packages without changing pacman's install reason database.",
    )
    args = parser.parse_args(argv)

    return run_preflight(
        declared=load_declared_pacman_packages(args.source),
        dep_installed=load_dep_installed_packages(),
        dry_run=args.dry_run,
        confirm=lambda prompt: input(prompt).lower() in {"y", "yes"},
        run=lambda cmd: subprocess.run(cmd, check=True),
    )


if __name__ == "__main__":
    raise SystemExit(main())
