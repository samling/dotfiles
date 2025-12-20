#!/usr/bin/env bash

# Catppuccin Mocha color definitions
# Model colors
REGULAR_COLOR='\033[1;38;2;243;139;168m'    # Red - regular models
BOLD_1M_COLOR='\033[0;38;2;30;30;46;48;2;249;226;175m'  # Dark on yellow bg - 1M models
# UI element colors
DIR_COLOR='\033[0;38;2;137;180;250m'        # Blue - directory
COST_COLOR='\033[0;38;2;203;166;247m'       # Mauve - cost
# Context usage gradient (Catppuccin Mocha)
CTX_GREEN='\033[0;38;2;166;227;161m'        # Green - low usage (0-50%)
CTX_YELLOW='\033[0;38;2;249;226;175m'       # Yellow - moderate (50-75%)
CTX_PEACH='\033[0;38;2;250;179;135m'        # Peach - high (75-90%)
CTX_RED='\033[1;38;2;243;139;168m'          # Red bold - critical (90%+)
RESET='\033[0m'

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.cwd')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd')

# Extract context window info using current_usage (actual context state)
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$input" | jq '.context_window.current_usage')

# Choose color based on whether model has "1M" in the name
if [[ "$MODEL_DISPLAY" =~ 1M ]]; then
    MODEL_COLOR="$BOLD_1M_COLOR"
else
    MODEL_COLOR="$REGULAR_COLOR"
fi

# Calculate context usage percentage from current_usage fields
if [[ "$USAGE" != "null" ]]; then
    CTX_USED=$(echo "$USAGE" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
else
    CTX_USED=0
fi

if [[ "$CTX_SIZE" -gt 0 && "$CTX_USED" -gt 0 ]]; then
    CTX_PCT=$(echo "scale=1; $CTX_USED * 100 / $CTX_SIZE" | bc)
else
    CTX_PCT="0"
fi

# Choose context color based on usage percentage
CTX_PCT_INT=${CTX_PCT%.*}
CTX_PCT_INT=${CTX_PCT_INT:-0}
if [[ "$CTX_PCT_INT" -ge 90 ]]; then
    CTX_COLOR="$CTX_RED"
elif [[ "$CTX_PCT_INT" -ge 75 ]]; then
    CTX_COLOR="$CTX_PEACH"
elif [[ "$CTX_PCT_INT" -ge 50 ]]; then
    CTX_COLOR="$CTX_YELLOW"
else
    CTX_COLOR="$CTX_GREEN"
fi

# Build base output
OUTPUT="${RESET}[${MODEL_COLOR}${MODEL_DISPLAY}${RESET}] in ${DIR_COLOR}${CURRENT_DIR}${RESET}"

# Append cost and context: "for $X.XX at YY% context"
if [[ -n "$COST" && "$COST" != "null" && $(echo "$COST > 0" | bc) -eq 1 ]]; then
    COST_FORMATTED=$(printf "%.2f" "$COST")
    OUTPUT="${OUTPUT} for \$${COST_COLOR}${COST_FORMATTED}${RESET} at ${CTX_COLOR}${CTX_PCT}%${RESET} context"
else
    OUTPUT="${OUTPUT} at ${CTX_COLOR}${CTX_PCT}%${RESET} context"
fi

echo -e "$OUTPUT"
