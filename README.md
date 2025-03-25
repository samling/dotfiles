### Dotfiles

My ever-growing collection of dotfiles and configs.

### Prereqs
* `git`
* `make`
* `direnv`
* [chezmoi](https://github.com/twpayne/chezmoi)

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
1. `chezmoi apply --refresh-externals`
1. `source ./install.sh | tee log` # `tee` also avoids the shell exiting if there is an error

### Notes
- See [this page](https://www.cyberciti.biz/faq/linux-unix-macos-fix-error-cant-open-display-null-with-ssh-xclip-command-in-headless/) to configure X11 forwarding over ssh

# Chezmoi Scripts

This directory contains scripts that are executed by chezmoi during apply operations.

## Package Installation

Packages are installed via `run_onchange_install-packages.sh.tmpl`. This script:

1. Determines the operating system
2. Builds lists of packages for each category from `.chezmoidata/packages.yaml`
3. Installs packages using the appropriate package manager (pacman for Arch, apt for Ubuntu, etc.)

### Package Categories

- **base**: Essential system packages (build tools, core utilities)
- **tools**: Common development and productivity tools
- **hyprland**: Packages for the Hyprland window manager (installed only if desktop.environment = "hyprland")
- **sway**: Packages for the Sway window manager (installed only if desktop.environment = "sway")
- **aur**: Arch User Repository packages (Arch Linux only, installed with yay)

### Adding New Packages

To add a new package, update `.chezmoidata/packages.yaml` following the template in `.chezmoitemplates/package_template.yaml`.

Example:
```yaml
tools:
  new-tool:
    arch_linux:
      name: new-tool
    ubuntu:
      name: new-tool
    macos:
      name: new-tool
```

### Configuration

To enable desktop environment-specific packages, add to your `chezmoi.yaml`:

```yaml
desktop:
  environment: hyprland  # or "sway"
``` 