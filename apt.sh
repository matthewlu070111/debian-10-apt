#!/usr/bin/env bash

# Root Perm
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Root Permission Needed."
    exit 1
fi

# Debian version check
if ! grep -qi "buster" /etc/os-release; then
    echo "ERROR: Debian 10 Only."
    exit 2
fi

SOURCES_LIST="/etc/apt/sources.list"

# Backup
if [[ -f "$SOURCES_LIST" ]]; then
    cp -a "$SOURCES_LIST" "${SOURCES_LIST}.bak-$(date +%Y%m%d_%H%M%S)"
fi

# ELTS
cat > "$SOURCES_LIST" << 'EOF'
# deb http://deb.freexian.com/extended-lts buster main

deb http://deb.freexian.com/extended-lts buster main contrib non-free
# deb-src http://deb.freexian.com/extended-lts buster main contrib non-free
EOF

# GPG
KEY_URL="https://deb.freexian.com/extended-lts/archive-key.gpg"
KEY_TMP="/tmp/elts-archive-key.gpg"
KEY_DEST="/etc/apt/trusted.gpg.d/freexian-archive-extended-lts.gpg"

if ! wget -q --show-progress "$KEY_URL" -O "$KEY_TMP"; then
    echo "ERROR: Internet Connection Failed."
    exit 3
fi

mv "$KEY_TMP" "$KEY_DEST" || {
    echo "ERROR: Failed to Install GPG Key."
    exit 4
}

chmod 644 "$KEY_DEST"

# Do Update
apt update -y

echo "Update complete."
