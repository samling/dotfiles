#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
wrapper="$repo_root/chezmoi/dot_local/bin/executable_wallust"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

fake_wallust="$tmpdir/wallust-real"
log="$tmpdir/args"

cat >"$fake_wallust" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$WALLUST_ARG_LOG"
SH
chmod +x "$fake_wallust"

WALLUST_BIN="$fake_wallust" WALLUST_ARG_LOG="$log" "$wrapper" run /tmp/wallpaper.png --quiet

grep -qx -- '-I' "$log"
grep -qx -- 'background' "$log"

WALLUST_BIN="$fake_wallust" WALLUST_ARG_LOG="$log" "$wrapper" run /tmp/wallpaper.png -I foreground

grep -qx -- '-I' "$log"
grep -qx -- 'foreground' "$log"
grep -qx -- 'background' "$log"
