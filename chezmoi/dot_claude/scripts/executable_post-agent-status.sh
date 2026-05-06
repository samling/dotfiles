#!/usr/bin/env bash
set -euo pipefail

pgrep -f 'agent-status server' >/dev/null 2>&1 || exit 0

curl -sS --max-time 1 --data-binary @- http://127.0.0.1:7878/hook >/dev/null 2>&1 || true
