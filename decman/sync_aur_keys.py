"""Auto-discover validpgpkeys for our AUR packages and append new
fingerprints to decman/modules/common/aur_keys.toml after prompting.

Default mode walks every decman/modules/**/*.py and pulls package
names from `@aur.packages`-decorated functions, then fetches each
package's PKGBUILD from AUR's cgit and parses validpgpkeys=(...).

Positional args restrict the scan to specific packages, handy for
transitive AUR deps that aren't declared at our top level (e.g.
libjpeg6-turbo, pulled in by dcvviewer-bin).

Usage:
  python decman/sync_aur_keys.py
  python decman/sync_aur_keys.py libjpeg6-turbo other-pkg

Network access required (aur.archlinux.org). The aurbuilder keyring
itself is populated by decman on the next `just apply` - this script
only edits the TOML.
"""

from __future__ import annotations

import argparse
import ast
import re
import subprocess
import sys
import tomllib
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MODULES_DIR = ROOT / "modules"
KEYS_TOML = MODULES_DIR / "common" / "aur_keys.toml"

PKGBUILD_URL = "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h={pkg}"
VALIDPGPKEYS_RE = re.compile(r"validpgpkeys\s*=\s*\((.*?)\)", re.DOTALL)
FINGERPRINT_RE = re.compile(r"[0-9A-Fa-f]{40}")


def find_declared_aur_packages() -> set[str]:
    """Walk decman/modules/**/*.py and extract string elements from
    set literals returned by functions decorated with `@aur.packages`.
    """
    packages: set[str] = set()
    for path in MODULES_DIR.rglob("*.py"):
        try:
            tree = ast.parse(path.read_text())
        except SyntaxError:
            continue
        for node in ast.walk(tree):
            if not isinstance(node, ast.FunctionDef):
                continue
            if not _has_aur_packages_decorator(node):
                continue
            for stmt in ast.walk(node):
                if isinstance(stmt, ast.Return) and isinstance(stmt.value, ast.Set):
                    for elt in stmt.value.elts:
                        if isinstance(elt, ast.Constant) and isinstance(elt.value, str):
                            packages.add(elt.value)
    return packages


def _has_aur_packages_decorator(fn: ast.FunctionDef) -> bool:
    for dec in fn.decorator_list:
        target = dec.func if isinstance(dec, ast.Call) else dec
        if (
            isinstance(target, ast.Attribute)
            and target.attr == "packages"
            and isinstance(target.value, ast.Name)
            and target.value.id == "aur"
        ):
            return True
    return False


def fetch_pkgbuild(pkg: str) -> str:
    url = PKGBUILD_URL.format(pkg=pkg)
    with urllib.request.urlopen(url, timeout=30) as r:
        return r.read().decode("utf-8", errors="replace")


def parse_validpgpkeys(pkgbuild: str) -> list[str]:
    fps: list[str] = []
    for m in VALIDPGPKEYS_RE.finditer(pkgbuild):
        for fp in FINGERPRINT_RE.findall(m.group(1)):
            fps.append(fp.upper())
    return fps


def load_known() -> set[str]:
    if not KEYS_TOML.exists():
        return set()
    with KEYS_TOML.open("rb") as f:
        data = tomllib.load(f)
    return {e["fingerprint"].upper() for e in data.get("entries", [])}


def lookup_key_uid(fingerprint: str, keyserver: str) -> str | None:
    """Best-effort lookup of the key's UID via the user's gpg, so the
    prompt can show 'Foo Bar <foo@bar.org>' alongside the fingerprint.
    Failure is non-fatal - returns None.
    """
    try:
        subprocess.run(
            ["gpg", "--keyserver", keyserver, "--recv-keys", f"0x{fingerprint}"],
            check=False,
            capture_output=True,
            timeout=30,
        )
        out = subprocess.run(
            ["gpg", "--with-colons", "--fingerprint", f"0x{fingerprint}"],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        ).stdout
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None
    for line in out.splitlines():
        if line.startswith("uid:"):
            parts = line.split(":")
            if len(parts) >= 10 and parts[9]:
                return parts[9]
    return None


def append_entry(pkg: str, fingerprint: str, uid: str | None) -> None:
    lines = ["", "[[entries]]", f'package = "{pkg}"', f'fingerprint = "{fingerprint}"']
    if uid:
        lines.append(f'note = "{uid.replace(chr(34), chr(39))}"')
    lines.append("")
    with KEYS_TOML.open("a") as f:
        f.write("\n".join(lines))


def prompt_yes(question: str) -> bool:
    try:
        ans = input(f"{question} [y/N] ").strip().lower()
    except EOFError:
        return False
    return ans in ("y", "yes")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "packages",
        nargs="*",
        help="Specific AUR package names to scan. Default: every @aur.packages declaration.",
    )
    parser.add_argument(
        "--keyserver",
        default="hkps://keyserver.ubuntu.com",
        help="Keyserver used for UID lookup (informational only).",
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="Auto-accept every new fingerprint. Use only when you trust the listed pkgs.",
    )
    args = parser.parse_args(argv)

    targets: set[str] = set(args.packages) or find_declared_aur_packages()
    if not targets:
        print("No AUR packages found.", file=sys.stderr)
        return 1

    known = load_known()
    added = 0
    skipped: list[tuple[str, str]] = []

    for pkg in sorted(targets):
        print(f"\n[{pkg}]")
        try:
            pb = fetch_pkgbuild(pkg)
        except urllib.error.HTTPError as e:
            print(f"  http {e.code}: {e.reason}")
            continue
        except Exception as e:
            print(f"  fetch failed: {e}")
            continue

        fps = parse_validpgpkeys(pb)
        if not fps:
            print("  no validpgpkeys")
            continue

        for fp in fps:
            if fp in known:
                print(f"  ok    {fp}")
                continue
            uid = lookup_key_uid(fp, args.keyserver)
            uid_str = f"  ({uid})" if uid else ""
            print(f"  NEW   {fp}{uid_str}")
            accept = args.yes or prompt_yes(f"  trust this key for {pkg}?")
            if accept:
                append_entry(pkg, fp, uid)
                known.add(fp)
                added += 1
            else:
                skipped.append((pkg, fp))

    print(f"\nAdded {added} entries to {KEYS_TOML.relative_to(ROOT.parent)}")
    if skipped:
        print("Skipped:")
        for pkg, fp in skipped:
            print(f"  {pkg}: {fp}")
    if added:
        print("Run `just apply` to import the new keys into the aurbuilder keyring.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
