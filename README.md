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
