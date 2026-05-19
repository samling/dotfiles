# pyinfra deploy for macOS, run by `just apply` via `uvx pyinfra @local`.
import os

from pyinfra import local

MODULES = os.path.join(os.environ.get("DOTFILES_ROOT", os.getcwd()), "macos", "modules")

local.include(os.path.join(MODULES, "packages.py"))
local.include(os.path.join(MODULES, "defaults.py"))
