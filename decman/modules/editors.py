import decman
from decman.plugins import pacman, aur


class EditorsModule(decman.Module):
    """Editors plus the LSP/formatter set our nvim config calls out to.

    `neovim` is declared in DevModule; this is the surrounding ecosystem.
    """

    def __init__(self):
        super().__init__("editors")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "buf",
            "gopls",
            "dockerfile-language-server",
            "lua-language-server",
            "mermaid-cli",
            "python-black",
            "python-isort",
            "rust-analyzer",
            "shfmt",
            "stylua",
            "typescript-language-server",
            "typst",
            "vim",
            "yaml-language-server",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "terraform-ls",
        }
