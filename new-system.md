### Prereqs
pacman: `just chezmoi go-yq`
aur: `doppler-cli-bin decman crudini`

### Steps

1. `doppler login` (note: updating doppler in-place requires `sudo`; do that first and then do `doppler login` separately)
1. `doppler setup`
1. `just init`
1. `just dry-run`
1. `just apply`
