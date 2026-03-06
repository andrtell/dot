#!/usr/bin/env bash
set -e

VERSION="nightly"
BASENAME="nvim-linux-x86_64"
FILENAME="${BASENAME}.tar.gz"

FROM_URL="https://github.com/neovim/neovim/releases/download/$VERSION/$FILENAME"

TEMP_DIR="$(mktemp -d)"
TEMP_FILE="$TEMP_DIR/$FILENAME"

INSTALL_DIR="/usr/local/nvim/"

wget -O $TEMP_FILE $FROM_URL
tar  -C $TEMP_DIR -x -f $TEMP_FILE 

sudo mv "$TEMP_DIR/$BASENAME/" /usr/local/nvim
