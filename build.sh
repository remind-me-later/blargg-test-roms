#!/usr/bin/env bash
# Builds Blargg's Game Boy test ROMs with RGBDS (rgbasm, rgblink, rgbfix).
# Tested with RGBDS 1.0.4. The hardware definitions come from the hardware.inc
# submodule (git submodule update --init).
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

if [ ! -f "$here/hardware.inc/hardware.inc" ]; then
    echo "hardware.inc is missing; run: git submodule update --init" >&2
    exit 2
fi

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

# option NAME OPTIONS: the value of NAME=value in the comma-separated OPTIONS
option() {
    local item
    for item in ${2//,/ }; do
        [[ $item == "$1="* ]] && { echo "${item#*=}"; return; }
    done
}

# build_rom SOURCE_DIR SOURCE_FILES OUTPUT PAD OPTIONS
#
# A multi-test ROM has several source files separated by |: the driver, which
# runs from bank 0, and the tests, each of which is assembled as one block of
# the ROM (BUILD_MULTI, MULTI_TEST) and linked with the driver.
#
# OPTIONS:
#   size=BYTES       pad the ROM to this size with the pad byte
#   checksum=bank0   the global checksum of the released ROM covers bank 0
#                    only: it was computed before the tests were added to it
build_rom() {
    local srcdir=$1 files=$2 out=$here/build/$3 pad=$4 options=${5:-}
    local -a sources objs=()
    IFS='|' read -r -a sources <<< "$files"
    mkdir -p "$(dirname "$out")"
    if [ ${#sources[@]} -eq 1 ]; then
        (cd "$here/$srcdir" && rgbasm -I common/ -I "$here/hardware.inc/" -o "$tmp/0.o" "${sources[0]}")
        objs=("$tmp/0.o")
    else
        local i
        (cd "$here/$srcdir" && rgbasm -I common/ -I "$here/hardware.inc/" -o "$tmp/driver.o" "${sources[0]}")
        objs=("$tmp/driver.o")
        for ((i = 1; i < ${#sources[@]}; i++)); do
            (cd "$here/$srcdir" && rgbasm -I common/ -I "$here/hardware.inc/" -D BUILD_MULTI=1 -D MULTI_TEST=$((i - 1)) \
                -o "$tmp/test$i.o" "${sources[i]}")
            objs+=("$tmp/test$i.o")
        done
    fi
    rgblink -p "$pad" -o "$out" "${objs[@]}"

    local size
    size=$(option size "$options")
    if [ -n "$size" ]; then
        local have
        have=$(stat -c %s "$out")
        if [ "$have" -lt "$size" ]; then
            head -c $((size - have)) /dev/zero | tr '\0' "$(printf '\\%03o' $((pad)))" >> "$out"
        fi
    fi

    if [ "$(option checksum "$options")" = bank0 ]; then
        rgbfix -f h "$out"
        local sum
        sum=$(head -c 16384 "$out" | od -An -v -tu1 -w16 \
            | awk '{ for (i = 1; i <= NF; i++) s += $i } END { print s % 65536 }')
        printf "$(printf '\\x%02x\\x%02x' $((sum >> 8)) $((sum & 255)))" \
            | dd of="$out" bs=1 seek=334 conv=notrunc status=none
    else
        rgbfix -f hg "$out"
    fi
}

built=0
failed=0
while IFS=$'\t' read -r srcdir file out pad options; do
    [[ -z $srcdir || $srcdir == \#* ]] && continue
    wanted "$out" || continue
    if ! build_rom "$srcdir" "$file" "$out" "$pad" "$options"; then
        echo "FAILED     $out"
        failed=$((failed + 1))
        continue
    fi
    built=$((built + 1))
    if [ $check -eq 1 ]; then
        if [ ! -f "$ref/$out" ]; then
            echo "MISSING    $out"
            failed=$((failed + 1))
        elif cmp -s "$here/build/$out" "$ref/$out"; then
            echo "identical  $out"
        else
            echo "DIFFERENT  $out"
            failed=$((failed + 1))
        fi
    else
        echo "built      $out"
    fi
done < "$here/roms.tsv"

# Every ROM of the reference has to be built too
if [ $check -eq 1 ] && [ ${#only[@]} -eq 0 ]; then
    while IFS= read -r -d '' rom; do
        rel=${rom#"$ref"/}
        if [ ! -f "$here/build/$rel" ]; then
            echo "NOT BUILT  $rel"
            failed=$((failed + 1))
        fi
    done < <(find "$ref" \( -name build -o -name .git \) -prune -o -name '*.gb' -print0)
fi

echo "$built built, $failed failed"
[ $failed -eq 0 ]
