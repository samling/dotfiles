{
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    home.packages = with pkgs; [
      neovim
      vim

      # LSP servers
      lua-language-server
      typescript-language-server
      rust-analyzer
      gopls
      terraform-ls
      yaml-language-server
      dockerfile-language-server
      buf
      nil

      # Formatters
      stylua
      black
      isort
      shfmt
    ];
  };
}
