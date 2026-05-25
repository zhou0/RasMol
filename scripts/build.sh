#!/bin/bash
set -e

# Detect OS
OS_TYPE="$(uname -s)"

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
        if [ ! -f "scripts/svg2icns.sh" ]; then
            curl -Lo scripts/svg2icns.sh https://raw.githubusercontent.com/magnusviri/svg2icns/master/svg2icns.sh
            chmod +x scripts/svg2icns.sh
        fi
        ./scripts/svg2icns.sh "$SVG_PATH"
        ICON_NAME="$(basename "${SVG_PATH%.svg}.icns")"
        if [ -f "$ICON_NAME" ]; then
            mv "$ICON_NAME" assets/rasmol.icns
        elif [ -f "${SVG_PATH%.svg}.icns" ]; then
            mv "${SVG_PATH%.svg}.icns" assets/rasmol.icns
        fi
    fi
}

# Build function for Linux
build_linux() {
    echo "Building for Linux..."
    if ! command -v rpmbuild >/dev/null 2>&1 || ! command -v cmake >/dev/null 2>&1; then
        echo "Some dependencies might be missing. If the build fails, try running:"
        echo "sudo apt update && sudo apt install -y rpm libx11-dev libxext-dev libxi-dev libhdf5-dev tcl-dev tk-dev bison libxpm-dev libdeflate-dev libjbig-dev liblerc-dev libwebp-dev libjpeg-dev icnsutils imagemagick inkscape"
    fi

    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DPIXELDEPTH=32
    cmake --build build --config Release

    # Prepare AppDir for AppImage
    rm -rf AppDir
    mkdir -p AppDir/usr
    cmake --install build --config Release --prefix AppDir/usr

    mkdir -p AppDir/usr/share/icons/hicolor/512x512/apps
    if [ -f "assets/rasmol.png" ]; then
        cp assets/rasmol.png AppDir/usr/share/icons/hicolor/512x512/apps/rasmol.png
        cp assets/rasmol.png AppDir/rasmol.png
    fi
    cp warpings/tcl/metadata/rasmol.desktop AppDir/

    # Download linuxdeploy if not present
    if [ ! -f "linuxdeploy-x86_64.AppImage" ]; then
        wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20251107-1/linuxdeploy-x86_64.AppImage
        chmod +x linuxdeploy-x86_64.AppImage
    fi

    LIBS_ARGS=""
    for lib in $(find build/lib build/_deps -name "*.so*" -not -path "*/CMakeFiles/*"); do
      LIBS_ARGS="$LIBS_ARGS --library $lib"
    done

    export ARCH=$(uname -m)
    mkdir -p build/AppImage
    # Run linuxdeploy
    ./linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir AppDir --output appimage $LIBS_ARGS || echo "AppImage generation failed"
    mv *.AppImage build/AppImage/ 2>/dev/null || true

    # DEB and RPM
    cd build
    cpack -G "DEB" || echo "DEB packaging failed"
    cpack -G "RPM" || echo "RPM packaging failed"
    mkdir -p DEB RPM
    mv *.deb DEB/ 2>/dev/null || true
    mv *.rpm RPM/ 2>/dev/null || true
    cd ..
}

# Build function for macOS
build_macos() {
    echo "Building for macOS..."
    if ! command -v port >/dev/null 2>&1; then
        echo "MacPorts not found. Please install it and dependencies if build fails:"
        echo "sudo port install bison tcl tk libjpeg-turbo hdf5 zstd webp lerc libdeflate jbigkit xz zlib"
    fi

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
