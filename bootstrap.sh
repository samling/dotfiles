#!/bin/bash

# Check dependencies
echo "Checking dependencies..."
missing=()
for cmd in doppler chezmoi jq direnv make; do
  command -v "$cmd" &>/dev/null || missing+=("$cmd")
done

if (( ${#missing[@]} )); then
  echo "Missing dependencies: ${missing[*]}"
  exit 1
else
  echo "All dependencies present; continuing..."
fi

# Check if doppler is configured
if ! doppler configure --json 2>/dev/null | jq -e '."/".token' &>/dev/null; then
  echo "Doppler is not configured. Run `doppler login` followed by `doppler setup`."
  exit 1
else
  echo "Doppler is already configured; continuing..."
fi

echo "Creating .envrc from template..."
doppler secrets substitute ./.envrc.tmpl > .envrc

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "\$GITHUB_TOKEN is empty; enabling direnv..."
  eval "$(direnv hook bash)"
  direnv allow .
  eval "$(direnv hook bash)"
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "\$GITHUB_TOKEN is still not set"
  exit 1
fi

# Refresh sudo credentials
sudo -v || exit 1

# Run sudo -v in a loop to refresh the credential cache
while true; do sudo -n true 2>/dev/null; sleep 60; done &
SUDO_PID=$!

if [[ ! -f "./.chezmoitemplates/hosts/$(hostname)" ]]; then
  echo "No host config found for $(hostname)"
  exit 1
fi

echo "Initializing chezmoi data..."
chezmoi init

chezmoi apply && \
  echo "Bootstrap complete!"

kill $SUDO_PID 2>/dev/null
