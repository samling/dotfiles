### Dotfiles

My ever-growing collection of dotfiles and configs.

### Prereqs
* `git`
* `make`
* `direnv`
* [bitwarden-cli](https://bitwarden.com/help/cli/)
* [chezmoi](https://github.com/twpayne/chezmoi)

### Bitwarden-cli tl;dr

1. Create `~/.bwpass` with password
1. export BW_SESSION=$(bw unlock --raw --passwordfile=/home/$USERNAME/.bwpass)

### Chezmoi tl;dr
```
chezmoi init <repo>
chezmoi apply {-n}          # Apply changes to ~ {Dry run}
chezmoi archive             # Create an archive of the dotfiles
chezmoi cd                  # cd to chosmoi source path
chezmoi merge               # Merge changes made to local copy with chezmoi managed
chezmoi update              # Pull latest version from git and apply changes

chezmoi add ~/.my_file      # Manage new file
chezmoi forget ~/.my_file   # Stop managing a file
chezmoi managed             # View managed files
```

### Installation

1. Copy `.envrc.example` to `.envrc`
1. Add `GITHUB_TOKEN`
1. Enable direnv with `eval "$(direnv hook bash)"
1. `direnv allow`
1. `chezmoi init`
1. `chezmoi apply {--refresh-externals}`

### Notes
- See [this page](https://www.cyberciti.biz/faq/linux-unix-macos-fix-error-cant-open-display-null-with-ssh-xclip-command-in-headless/) to configure X11 forwarding over ssh

# Chezmoi Scripts

This directory contains scripts that are executed by chezmoi during apply operations.

## Package Installation

Packages are installed via scripts in `.chezmoiscripts`. These scripts:

1. Determine the operating system (or which OS it is most like, e.g. EndeavourOS will return `arch`)
1. Build a list of packages for each category from `.chezmoidata/packages.yaml`
1. Installs packages using the appropriate package manager (pacman for Arch, apt for Ubuntu, etc.)
1. Configure tools (nvim, zsh, tmux, etc.)
1. Download plugins for above tools
1. Put `.config` files in place
1. And more!

### Package Categories

- **base**: Essential system packages, user tools, fonts, libraries, etc.
- **laptop**: System packages that only make sense for laptops
- **hyprland**: Packages for the Hyprland window manager (installed only if desktop.environment = "hyprland")
- **sway**: Packages for the Sway window manager (installed only if desktop.environment = "sway")

### Adding New Packages

To add a new package, update `.chezmoidata/packages.yaml` following the template in `.chezmoitemplates/package_template.yaml`.

Example:
```yaml
packages:
  taps:
    darwin:
      - tap/name
  base:
    new-tool:
      # add package names per package manager tool here
      # omissions will simply be skipped for that OS
      pacman: new-tool
      yay: new-tool
      apt: new-tool
      brew: new-tool
```
