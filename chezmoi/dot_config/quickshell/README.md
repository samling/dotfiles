# Quickshell Configuration

## Permissions

Controlling the fan state, governor, and mute LED requires passwordless sudo:

```bash
# /etc/sudoers.d/quickshell
sboynton ALL=(ALL) NOPASSWD: /usr/bin/fan_state
sboynton ALL=(ALL) NOPASSWD: /usr/bin/cpupower
sboynton ALL=(ALL) NOPASSWD: /usr/bin/sh -c echo [01] > /sys/class/leds/platform\:\:micmute/brightness
```

## Files

- `common/palette.json` - Color theme (Catppuccin Mocha by default)
- `common/config.json` - User configuration

## User Config (`common/config.json`)

```json
{
  "updates": {
    "criticalPackages": ["glibc", "linux*", "systemd"],
    "warningPackages": ["hyprland", "nvidia*", "pacman", "paru", "yay"]
  }
}
```

### Priority Levels

| Level | Icon | Color | Example |
|-------|------|-------|---------|
| Critical | ⚠ | Red | Kernel, glibc, systemd |
| Warning | ★ | Yellow | Drivers, package managers |
| Normal | — | Default | Everything else |

Packages are sorted: critical first, then warning, then normal (alphabetically within each group).

### Pattern Matching

| Pattern | Matches |
|---------|---------|
| `hyprland` | Exact match only |
| `hyprland*` | Starts with "hyprland" |
| `*-git` | Ends with "-git" |
| `*linux*` | Contains "linux" |
