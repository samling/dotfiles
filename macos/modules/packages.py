# Packages: brew bundle for the Brewfile, uv for CLI tools with no formula.
import os

from pyinfra.operations import server

ROOT = os.environ.get("DOTFILES_ROOT", os.getcwd())
BREWFILE = os.path.join(ROOT, "macos", "Brewfile")

server.shell(
    name="brew bundle",
    commands=[f"brew bundle --file={BREWFILE}"],
)

# Tools with no Homebrew formula; uv keeps each in its own isolated venv.
for tool in ["crudini"]:
    server.shell(
        name=f"uv tool install {tool}",
        commands=[f"uv tool install --quiet {tool}"],
    )
