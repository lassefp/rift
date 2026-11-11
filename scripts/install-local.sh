#!/bin/sh
# Build rift, install it to ~/.local/bin, sign it with a stable identity and restart the service.
# A fixed signing identity keeps the Accessibility grant across rebuilds (ad-hoc signatures don't).
set -eu

IDENTITY="${RIFT_SIGN_IDENTITY:-rift-dev}"
BIN="$HOME/.local/bin"

cd "$(dirname "$0")/.."
cargo build --release --bin rift --bin rift-cli

mkdir -p "$BIN"
for name in rift rift-cli; do
	install -m 755 "target/release/$name" "$BIN/$name"
	codesign --force --sign "$IDENTITY" --identifier "git.acsandmann.$name" "$BIN/$name"
done

# `service start` points the launch agent at the first `rift` on PATH (restart doesn't).
"$BIN/rift" service stop || true
"$BIN/rift" service start
"$BIN/rift" --version
