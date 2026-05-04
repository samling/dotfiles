#!/usr/bin/sh
# Send SIGTERM only to the top-level chrome process (no --type= in argv);
# chrome itself orchestrates shutdown of its renderer/utility kids and writes
# exit_type=Normal so the next launch doesn't show "didn't shut down correctly".
set -u
main_pid=""
for pid in $(/usr/bin/pgrep -x chrome 2>/dev/null); do
  args=$(tr '\0' ' ' < /proc/"$pid"/cmdline 2>/dev/null) || continue
  case "$args" in
    *--type=*) ;;
    *) main_pid="$pid"; break ;;
  esac
done
[ -n "$main_pid" ] || exit 0
kill -TERM "$main_pid" 2>/dev/null || exit 0
for _ in $(seq 1 30); do
  kill -0 "$main_pid" 2>/dev/null || exit 0
  sleep 0.2
done
