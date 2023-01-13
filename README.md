### Dotfiles

My ever-growing collection of dotfiles and configs.

### Prereqs
* `git`
* `make`

### In-use

* .vim/
* .vimrc
* .zshrc
* .zshrc.local (separate repo)
* .tmux/
* .tmux.conf

### To use

* `sudo -E make`

### Notes/Troubleshooting
- For the `kube-tmux` plugin to work, the file `~/.kube/config` must exist. The contents of this file presumably get swapped by `kubectx`.
