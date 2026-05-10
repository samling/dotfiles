"""Shared path helpers for module files.

Defining the pkgbuilds/ path here (instead of recomputing
`Path(__file__).resolve().parents[N] / "pkgbuilds"` in every module
that ships a CustomPackage) keeps the level count in one place — so
moving module files between subdirectories doesn't silently break
the lookup.

The repo layout is:

    <dotfiles>/
      decman/        <- source.py, modules/, roles/, hosts/
      pkgbuilds/     <- bundled PKGBUILDs
      etc/           <- config-file source dirs
"""
from pathlib import Path

# parents[1] from modules/_paths.py is decman/; pkgbuilds/ lives one
# level up alongside it.
PKGBUILDS = Path(__file__).resolve().parents[2] / "pkgbuilds"
