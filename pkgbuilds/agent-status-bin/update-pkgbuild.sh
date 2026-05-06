#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

updpkgsums && \
  echo "Removing artifacts..." && \
  rm -rf ${SCRIPT_DIR}/agent-status-*.tar.gz; \
  echo -n "done."
