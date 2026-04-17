### Dotfiles

My ever-growing collection of dotfiles and configs.

### Prereqs
* `git`
* `make`
* `direnv`
* [doppler cli](https://aur.archlinux.org/packages/doppler-cli-bin)
* [chezmoi](https://github.com/twpayne/chezmoi)
* [metapac](https://github.com/ripytide/metapac)

### Doppler CLI tl;dr

`doppler login`
`doppler setup`

### Chezmoi tl;dr
```bash
chezmoi init <repo>
chezmoi apply {-n}          # Apply changes to ~ {Dry run}
chezmoi archive             # Create an archive of the dotfiles
chezmoi cd                  # cd to chezmoi source path
chezmoi merge               # Merge changes made to local copy with chezmoi-managed file
chezmoi update              # Pull latest version from git and apply changes

chezmoi add ~/.my_file      # Manage new file
chezmoi forget ~/.my_file   # Stop managing a file
chezmoi managed             # View managed files
```

### Metapac tl;dr
```bash
metapac sync                # Install all missing packages
metapac clean               # (Interactively) clean removed packages
metapac unmanaged           # Show explicitly installed packages not required by metapac
```

### Installation

1. `doppler login`
1. `doppler setup`
1. `doppler secrets substitute ./.envrc.tmpl > .envrc`
1. Enable direnv with `eval "$(direnv hook bash)"`
1. `direnv allow`
1. `chezmoi init`
1. `chezmoi apply {--refresh-externals}`
1. (Optional) `metapac sync && metapac clean`

### Notes
- See [this page](https://www.cyberciti.biz/faq/linux-unix-macos-fix-error-cant-open-display-null-with-ssh-xclip-command-in-headless/) to configure X11 forwarding over ssh

# Chezmoi Scripts

This directory contains scripts that are executed by chezmoi during apply operations.

## Package Installation

Packages are managed by metapac. Groups are defined in `./dot_config/metapac/groups/`.

### Adding New Packages

To add a new package, update the corresponding group file, e.g. `./dot_config/metapac/groups/40-cli-tools.toml`.

Install it with `metapac sync`. Run `metapac clean` to remove packages no longer declared.
