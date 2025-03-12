#!/bin/bash
# Note: PLAY.EXE is currently missing.
BASE_URL="https://raw.githubusercontent.com/AnimatorPro/Animator-Pro/f5ed37135ad1f3e2788a43a25774eb46b2c0cc9a/bin/dos/v"
CACHE_DIR="$HOME/.cache/animatorpro-fdpkg"
AA_SHA256="6a5a45dff74e2dad5d8ec5d77b5a3c584651714c642bbb53fce0d72263e44172"
CROP_SHA256="74a86a337199742a0c8202237f679dbb719cc4f8e739097fd59ed5575d59268b"
V_SHA256="a66c9eda15f148098da58d839586973c679cfed0276efcf5bd7cd7fb0425455b"

fetch_binaries() {

    mkdir -p "$CACHE_DIR"

    FILES=("AA.CFG" "CROP.EXE" "V.EXE")
    echo "Download:"

    for file in "${FILES[@]}"; do
        printf "⏳ %s..." "$file"
        if curl -s -L "$BASE_URL/$file" -o "$CACHE_DIR/$file"; then
            printf "\r\033[K✓ %s\n" "$file"
        else
            printf "\r\033[K✗ %s\n" "$file"
        fi
    done
}

verify_sha256() {
    local filename="$1"
    local expected="$2"
    if [ ! -f "$CACHE_DIR/$filename" ]; then
        echo "✗ $filename: File not found!"
        return 2
    fi
    local actual
    actual=$(sha256sum "$CACHE_DIR/$filename" | cut -d' ' -f1)
    if [ "$actual" != "$expected" ]; then
        echo "✗ $filename: Checksum mismatch!"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
    echo "✓ $filename"
    return 0
}

verify_binaries() {
    echo "Verify:"
    local status=0

    if ! verify_sha256 "AA.CFG" "$AA_SHA256"; then
        status=1
    fi
    if ! verify_sha256 "CROP.EXE" "$CROP_SHA256"; then
        status=1
    fi
    if ! verify_sha256 "V.EXE" "$V_SHA256"; then
        status=1
    fi
    return $status
}

create_fdpkg() {
    echo "Package:"
    local temp_dir
    temp_dir=$(mktemp -d -t animator-fdpkg-XXXXXX)

    mkdir -p "$temp_dir/APPINFO"
    mkdir -p "$temp_dir/LINKS"
    mkdir -p "$temp_dir/PROGS/ANIMATOR"
    mkdir -p "$temp_dir/SOURCE"

    cp "./APPINFO/ANIMATOR.LSM" "$temp_dir/APPINFO/"
    cp "$CACHE_DIR/AA.CFG" "$temp_dir/PROGS/ANIMATOR/"
    cp "$CACHE_DIR/CROP.EXE" "$temp_dir/PROGS/ANIMATOR/"
    cp "$CACHE_DIR/V.EXE" "$temp_dir/PROGS/ANIMATOR/"

    echo "PROGS\ANIMATOR\V.EXE" > "$temp_dir/LINKS/ANIMATOR.BAT"
    echo "PROGS\ANIMATOR\CROP.EXE" > "$temp_dir/LINKS/ANIMCROP.BAT"
    (cd "$temp_dir" && zip -q -9 -k -r "$(pwd)/ANIMATOR.ZIP" APPINFO LINKS PROGS SOURCE)

    mv "$temp_dir/ANIMATOR.ZIP" ./

    rm -rf "$temp_dir"
    echo "✓ ANIMATOR.ZIP"
}

main() {
    fetch_binaries
    echo ""

    local verify_status
    verify_binaries
    verify_status=$?
    echo ""
    if [ $verify_status -ne 0 ]; then
        exit 1
    fi

    create_fdpkg
}

main
