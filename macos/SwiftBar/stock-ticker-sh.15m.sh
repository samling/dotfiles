#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_PATH="stock-ticker/stock-ticker.py"
LOGFILE="$SCRIPT_DIR/stock-ticker.log"

# echo "loading envrc" >> "$LOGFILE"
if [ -f "$SCRIPT_DIR/.envrc" ]; then
    source "$SCRIPT_DIR/.envrc"
    # echo "source $SCRIPT_DIR/.envrc" >> "$LOGFILE"
fi

if [ -f "$SCRIPT_DIR/.python-version" ]; then
    PYTHON_VERSION=$(cat "$SCRIPT_DIR/.python-version")
    if command -v /opt/homebrew/bin/pyenv > /dev/null 2>&1; then
        # echo "pyenv found" >> "$LOGFILE"
        eval "$(/opt/homebrew/bin/pyenv init -)"

        # /opt/homebrew/bin/pyenv shell "$PYTHON_VERSION"
        export PYENV_VERSION="$PYTHON_VERSION"
        # echo "pyenv shell $PYTHON_VERSION" >> "$LOGFILE"

        echo "$(python3 $SCRIPT_DIR/$SCRIPT_PATH)"

        unset PYENV_VERSION
    else
        echo "pyenv not found"
    fi
fi

