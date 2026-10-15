#!/bin/sh
# Compares ROMs, byte for byte, with the ones of the gameboy-test-roms release.
#
#   ./compare-roms.sh BUILD REFERENCE ROM...
#
# Each ROM is a path under BUILD. Its reference is the file at the same path
# under REFERENCE, where the release has the names it has: the sources have no
# spaces, commas or parentheses in them, so these are left out of the names of
# the reference when matching (03-op sp,hl.gb is 03-op_sp_hl.gb).
#
# The exit status is 1 if a ROM differs, has no reference, or if a ROM of the
# reference is not in the list.

set -eu

if [ $# -lt 3 ]; then
    echo "usage: $0 BUILD REFERENCE ROM..." >&2
    exit 2
fi

build=$1
ref=$2
shift 2

if [ ! -d "$ref" ]; then
    echo "no ROMs to compare with in $ref (./fetch-reference.sh downloads them)" >&2
    exit 2
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# the ROMs of the reference, by the name the sources give them
(cd "$ref" && find . -name '*.gb' | sed 's|^\./||') | while IFS= read -r rel; do
    key=$(printf '%s' "$rel" | tr ' ,' '__' | tr -d '()')
    printf '%s\t%s\n' "$key" "$rel"
done | sort > "$tmp/reference"

printf '%s\n' "$@" | sort > "$tmp/built"

status=0
ok=0
bad=0
while IFS= read -r rom; do
    rel=$(awk -F'\t' -v k="$rom" '$1 == k { print $2; exit }' "$tmp/reference")
    if [ -z "$rel" ]; then
        echo "MISSING    $rom"
        bad=$((bad + 1))
    elif cmp -s "$build/$rom" "$ref/$rel"; then
        echo "identical  $rom"
        ok=$((ok + 1))
    else
        echo "DIFFERENT  $rom"
        bad=$((bad + 1))
    fi
done < "$tmp/built"

# every ROM of the reference has to be built too
cut -f1 "$tmp/reference" | sort | comm -23 - "$tmp/built" > "$tmp/notbuilt"
while IFS= read -r rom; do
    echo "NOT BUILT  $rom"
    bad=$((bad + 1))
done < "$tmp/notbuilt"

echo "$ok identical, $bad different or missing"
[ $bad -eq 0 ]
