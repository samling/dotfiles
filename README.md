# Dotfiles

Personal dotfiles mainly for Arch Linux-based and MacOS machines.

## 1. Layout

| File(s)/Folder(s) | Description |
| --- | --- |
| `chezmoi/` | declarative file management for the home directory |
| `decman/` | composable python modules for declaratively managing an Arch-based system |
| `etc/` | files destined for `/etc/` (managed by decman) |
| `pkgbuilds/` | local Arch packages |
| `scripts/` | supporting scripts |


## 2. Bootstrapping

Install prerequisites:
```bash
{yay/paru} -S just chezmoi go-yq doppler-cli-bin decman crudini
```

Configure `gh`:
1. `gh auth login`
1. `cp .envrc.tmpl .envrc`
1. `direnv allow`

Configure `doppler`:
1. `doppler login`
1. `doppler setup`

Configure and run `chezmoi` and `decman`:
1. `just init`
1. `just dry-run`
1. `just apply`

Apply any manual theme configuration in [THEMING.md](./THEMING.md)

## 3. Reference

### Daily use

```
just init          # initialize chezmoi and decman source directories
just apply         # run chezmoi followed by decman
just dry-run       # do a dry-run of `decman`
just update        # run decman without doing a system upgrade
```

### Chezmoi reference

```
chezmoi init --source $(pwd) # initialize chezmoi in the current directory
chezmoi apply {-n}           # apply changes to ~ (dry run with -n)
chezmoi merge                # merge local edits back into chezmoi source
chezmoi update               # pull latest + apply
chezmoi add ~/.my_file       # manage a new file
chezmoi forget ~/.my_file    # remove a file
chezmoi managed              # list managed files
```

### Decman reference

```
sudo decman --source=(...)   # first-time decman setup to declare the source of truth
sudo decman                  # do a system upgrade followed by applying decman modules
```
