#!/bin/bash
set -e

# Detect OS
OS_TYPE="$(uname -s)"
RAW_ARCH="$(uname -m)"

# Icon generation function
generate_icons() {
    SVG_PATH="./website/static/img/rasmol-logo.svg"
    mkdir -p assets

    if [ "$OS_TYPE" = "Linux" ]; then
        echo "Generating icons for Linux..."
        if command -v inkscape >/dev/null 2>&1; then
            inkscape -w 512 -h 512 "$SVG_PATH" -o assets/rasmol.png
        elif command -v convert >/dev/null 2>&1; then
            convert -background none "$SVG_PATH" -resize 512x512 assets/rasmol.png
        else
            echo "Warning: inkscape or imagemagick not found. Skipping high-res icon generation."
            if [ -f "src/rasmol_48x48.xpm" ] && command -v convert >/dev/null 2>&1; then
                convert src/rasmol_48x48.xpm assets/rasmol.png
            fi
        fi
    elif [ "$OS_TYPE" = "Darwin" ]; then
        echo "Generating icons for macOS..."
        ICONSET="assets/rasmol.iconset"
        mkdir -p "$ICONSET"

        # Render SVG to various PNG sizes for iconset
        for size in 16 32 128 256 512; do
            s2=$((size * 2))
            if command -v inkscape >/dev/null 2>&1; then
                inkscape -w $size -h $size "$SVG_PATH" -o "$ICONSET/icon_${size}x${size}.png"
                inkscape -w $s2 -h $s2 "$SVG_PATH" -o "$ICONSET/icon_${size}x${size}@2x.png"
            elif command -v magick >/dev/null 2>&1; then
                magick -background none "$SVG_PATH" -resize ${size}x${size} "$ICONSET/icon_${size}x${size}.png"
                magick -background none "$SVG_PATH" -resize ${s2}x${s2} "$ICONSET/icon_${size}x${size}@2x.png"
            elif command -v convert >/dev/null 2>&1; then
                convert -background none "$SVG_PATH" -resize ${size}x${size} "$ICONSET/icon_${size}x${size}.png"
                convert -background none "$SVG_PATH" -resize ${s2}x${s2} "$ICONSET/icon_${size}x${size}@2x.png"
            else
                # Fallback to qlmanage if available
                if command -v qlmanage >/dev/null 2>&1; then
                    qlmanage -t -s $size -o "$ICONSET" "$SVG_PATH" >/dev/null 2>&1
                    mv "$ICONSET/$(basename "$SVG_PATH").png" "$ICONSET/icon_${size}x${size}.png" 2>/dev/null || true
                    qlmanage -t -s $s2 -o "$ICONSET" "$SVG_PATH" >/dev/null 2>&1
                    mv "$ICONSET/$(basename "$SVG_PATH").png" "$ICONSET/icon_${size}x${size}@2x.png" 2>/dev/null || true
                fi
            fi
        done

        if command -v iconutil >/dev/null 2>&1; then
            iconutil -c icns "$ICONSET" -o assets/rasmol.icns
            rm -rf "$ICONSET"
        else
            echo "Error: iconutil not found. Cannot generate .icns file."
        fi
    fi
}

# Build function for Linux
build_linux() {
    echo "Building for Linux ($RAW_ARCH)..."

    # Determine linuxdeploy architecture name
    case "$RAW_ARCH" in
        x86_64)  LD_ARCH="x86_64" ;;
        aarch64) LD_ARCH="aarch64" ;;
        arm64)   LD_ARCH="aarch64" ;;
        *)       LD_ARCH="$RAW_ARCH" ;;
    esac

    # Determine Package format based on /etc/os-release
    PKG_GEN="TGZ"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
            PKG_GEN="DEB"
            echo "Detected Debian/Ubuntu system. Will generate DEB."
        elif [[ "$ID" == "fedora" || "$ID" == "centos" || "$ID" == "rhel" || "$ID_LIKE" == *"fedora"* ]]; then
            PKG_GEN="RPM"
            echo "Detected Fedora/RHEL system. Will generate RPM."
        elif [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
            PKG_GEN="TXZ"
            if cpack --help | grep -q "ZST"; then
                PKG_GEN="ZST"
            fi
            echo "Detected Arch Linux system. Will generate $PKG_GEN."
        fi
    fi

    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DPIXELDEPTH=32
    cmake --build build --config Release

    # Prepare AppDir for AppImage inside build directory
    rm -rf build/AppDir
    mkdir -p build/AppDir/usr
    cmake --install build --config Release --prefix build/AppDir/usr

    mkdir -p build/AppDir/usr/share/icons/hicolor/512x512/apps
    if [ -f "assets/rasmol.png" ]; then
        cp assets/rasmol.png build/AppDir/usr/share/icons/hicolor/512x512/apps/rasmol.png
        cp assets/rasmol.png build/AppDir/rasmol.png
    fi
    cp warpings/tcl/metadata/rasmol.desktop build/AppDir/

    # Download linuxdeploy if not present, arch-aware
    LD_FILENAME="linuxdeploy-${LD_ARCH}.AppImage"
    if [ ! -f "$LD_FILENAME" ]; then
        echo "Downloading $LD_FILENAME..."
        wget -q "https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20251107-1/$LD_FILENAME"
        chmod +x "$LD_FILENAME"
    fi

    # Ensure all library paths are in LD_LIBRARY_PATH for linuxdeploy
    LIB_PATHS=$(find build/lib build/_deps -name "*.so*" -printf "%h:" | sort -u | tr -d "\n")
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB_PATHS

    LIBS_ARGS=""
    for lib in $(find build/lib build/_deps -name "*.so*" -not -path "*/CMakeFiles/*"); do
      LIBS_ARGS="$LIBS_ARGS --library $lib"
    done

    export ARCH="$RAW_ARCH"
    mkdir -p build/AppImage
    ./"$LD_FILENAME" --appimage-extract-and-run --appdir build/AppDir --output appimage $LIBS_ARGS || echo "AppImage generation failed"
    mv *.AppImage build/AppImage/ 2>/dev/null || true

    # Native package (DEB/RPM/etc)
    cd build
    echo "Generating $PKG_GEN package..."
    cpack -G "$PKG_GEN" || echo "$PKG_GEN packaging failed"
    mkdir -p "$PKG_GEN"

    case "$PKG_GEN" in
        DEB) mv *.deb DEB/ 2>/dev/null || true ;;
        RPM) mv *.rpm RPM/ 2>/dev/null || true ;;
        TXZ) mv *.tar.xz TXZ/ 2>/dev/null || true ;;
        ZST) mv *.tar.zst ZST/ 2>/dev/null || true ;;
    esac
    cd ..
}

# Build function for macOS
build_macos() {
    echo "Building for macOS ($RAW_ARCH)..."
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DPIXELDEPTH=32
    cmake --build build --config Release

    cd build
    cpack -G DragNDrop
    cd ..
}

# Main execution
generate_icons

if [ "$OS_TYPE" = "Linux" ]; then
    build_linux
elif [ "$OS_TYPE" = "Darwin" ]; then
    build_macos
else
    echo "Unsupported OS: $OS_TYPE"
fi

echo "Build process completed."
