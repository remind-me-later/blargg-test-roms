#!/usr/bin/env bash
# Builds Blargg's Game Boy test ROMs with RGBDS (rgbasm, rgblink, rgbfix).
# Tested with RGBDS 1.0.4.
#
#   ./build.sh                  build every ROM listed in roms.tsv into build/
#   ./build.sh --check [DIR]    also compare each ROM, byte for byte, with the one
#                               at the same path under DIR (default: this directory,
#                               which holds the ROMs released with the sources)
#   ./build.sh --only PREFIX    only the ROMs whose output path starts with PREFIX
#                               (can be repeated)
#
# The exit status is 1 if a ROM fails to build or differs from its reference.

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
check=0
ref=$here
only=()

usage() {
    sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

while [ $# -gt 0 ]; do
    case $1 in
        --check)
            check=1
            if [ $# -gt 1 ] && [[ $2 != -* ]]; then
                ref=$(cd "$2" && pwd)
                shift
            fi
            ;;
        --only) only+=("$2"); shift ;;
        -h | --help) usage 0 ;;
        *) echo "unknown argument: $1" >&2; usage 2 ;;
    esac
    shift
done

for tool in rgbasm rgblink rgbfix; do
    command -v "$tool" > /dev/null || { echo "$tool not found; install RGBDS" >&2; exit 2; }
done

wanted() {
    [ ${#only[@]} -eq 0 ] && return 0
    local prefix
    for prefix in "${only[@]}"; do
        [[ $1 == "$prefix"* ]] && return 0
    done
    return 1
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# build_rom SOURCE_DIR SOURCE_FILE OUTPUT PAD
build_rom() {
    local srcdir=$1 file=$2 out=$here/build/$3 pad=$4
    mkdir -p "$(dirname "$out")"
    (cd "$here/$srcdir" && rgbasm -I common/ -o "$tmp/rom.o" "$file")
    rgblink -p "$pad" -o "$out" "$tmp/rom.o"
    rgbfix -f hg "$out"
}

built=0
failed=0
while IFS=$'\t' read -r srcdir file out pad; do
    [[ -z $srcdir || $srcdir == \#* ]] && continue
    wanted "$out" || continue
    if ! build_rom "$srcdir" "$file" "$out" "$pad"; then
        echo "FAILED     $out"
        failed=$((failed + 1))
        continue
    fi
    built=$((built + 1))
    if [ $check -eq 1 ]; then
        if cmp -s "$here/build/$out" "$ref/$out"; then
            echo "identical  $out"
        else
            echo "DIFFERENT  $out"
            failed=$((failed + 1))
        fi
    else
        echo "built      $out"
    fi
done < "$here/roms.tsv"

echo "$built built, $failed failed"
[ $failed -eq 0 ]
