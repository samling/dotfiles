### Dotfiles

My ever-growing collection of dotfiles and configs.

### Prereqs
* `git`
* `make`
* `direnv`

### Installation

1. Copy `.envrc.example` to `.envrc`
1. Add `GITHUB_TOKEN`
1. `direnv allow`
1. `source ./install.sh | tee log` # `tee` also avoids the shell exiting if there is an error

### Notes
- See [this page](https://www.cyberciti.biz/faq/linux-unix-macos-fix-error-cant-open-display-null-with-ssh-xclip-command-in-headless/) to configure X11 forwarding over ssh
