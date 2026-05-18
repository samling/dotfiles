local flake = vim.env.HOME .. "/dotfiles"
local hostname = vim.fn.hostname()

---@type vim.lsp.Config
return {
    cmd = { "nixd" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", ".git" },
    settings = {
        nixd = {
            nixpkgs = {
                expr = ('(builtins.getFlake "%s").inputs.nixpkgs.legacyPackages.x86_64-linux'):format(flake),
            },
            options = {
                nixos = {
                    expr = ('(builtins.getFlake "%s").nixosConfigurations."%s".options'):format(flake, hostname),
                },
            },
        },
    },
}
