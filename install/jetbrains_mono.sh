#!/usr/bin/env bash
set -e

VERSION="2.304"
BASENAME="JetBrainsMono-${VERSION}"
FILENAME="${BASENAME}.zip"

FROM_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v$VERSION/$FILENAME"

TEMP_DIR="$(mktemp -d)"
TEMP_FILE="$TEMP_DIR/$FILENAME"
TEMP_FONT_DIR="$TEMP_DIR/fonts/ttf"

INSTALL_DIR="$HOME/.local/share/fonts/$BASENAME/"

wget -O $TEMP_FILE $FROM_URL
unzip $TEMP_FILE -d $TEMP_DIR
mkdir -p  $INSTALL_DIR
cp -i  $TEMP_FONT_DIR/* "$INSTALL_DIR/"
rm -rf $TEMP_DIR
fc-cache -f

