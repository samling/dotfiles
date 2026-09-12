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

Host configuration is selected automatically from the hostname:
`ada` loads `decman/hosts/ada.py`.

| Host | System | Purpose |
| --- | --- | --- |
| `ada` | EndeavourOS, Intel CPU, NVIDIA Turing or newer, systemd-boot + dracut | Work workstation: shared GUI/development tools plus `WorkModule`, no gaming |
| `titan` | CachyOS, NVIDIA, Limine + mkinitcpio | Work and gaming |
| `xen` | EndeavourOS Zenbook, systemd-boot + dracut | Laptop and gaming |
| `Sam-Desktop` | WSL2 | Windows-hosted development |

Gaming is opt-in at the host level, not part of `roles/gui.py`. Ada omits
Steam, Heroic, Moonlight, VirtualHere, Gamescope and Steam's firewall service
definition. It retains the shared desktop/media/development stack, Parsec,
RustDesk client, NVIDIA graphics/OpenCL/video tools and all of `WorkModule`.
NVIDIA's 32-bit compatibility libraries are omitted on Ada. Titan's UPS,
Sunshine and RustDesk server setup are not copied.

Before applying Ada's configuration:

- Install EndeavourOS with **systemd-boot and dracut**, and set its hostname
  to `ada`. The config does not partition disks, set up the EFI mount, or
  install/configure the bootloader itself.
- Keep the EndeavourOS repository enabled. Ada uses `linux` and `linux-lts`
  with headers, `nvidia-open-dkms` and `intel-ucode`. The shared firmware
  module also declares `amd-ucode`; both packages can safely coexist.
- Follow the bootstrap steps above and inspect `just dry-run` on **Ada**
  before applying, especially installer packages proposed for removal.
- User configuration still targets `sboynton`; credentials, work secrets,
  and data need their normal separate setup/migration.

Read-only host composition regression checks (requires Python and decman):

```bash
python -m unittest discover -s decman/tests -v
```
