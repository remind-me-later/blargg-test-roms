#!/usr/bin/env bash
# Downloads the Blargg ROMs of the gameboy-test-roms release, which
# `make check` compares the built ROMs with. They are not kept in this
# repository.
#
#   ./fetch-reference.sh [DIR]    default DIR: reference/ (ignored by git)
#
# The release is pinned: its SHA-256 is checked after the download.

set -euo pipefail

version=v7.0
sha256=b9a9d7a1075aa35a3d07c07c34974048672d8520dca9e07a50178f5860c3832c
url=https://github.com/c-sp/gameboy-test-roms/releases/download/$version/game-boy-test-roms-$version.zip

here=$(cd "$(dirname "$0")" && pwd)
dir=${1:-$here/reference}

for tool in curl unzip sha256sum; do
    command -v "$tool" > /dev/null || { echo "$tool not found" >&2; exit 2; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/roms.zip" "$url"
echo "$sha256  $tmp/roms.zip" | sha256sum -c --quiet -
unzip -q "$tmp/roms.zip" 'blargg/*' -d "$tmp/out"

rm -rf "$dir"
mkdir -p "$(dirname "$dir")"
mv "$tmp/out/blargg" "$dir"
echo "ROMs of gameboy-test-roms $version in $dir"
