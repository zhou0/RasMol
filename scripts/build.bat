@echo off
setlocal

echo Checking dependencies...
choco install imagemagick -y
choco install magicsplat-tcl-tk --version=1.16.0 -y

echo Generating icons for Windows...
set SVG_PATH=website\static\img\rasmol-logo.svg
if not exist assets mkdir assets
magick -background none %SVG_PATH% -define icon:auto-resize=256,128,64,48,32,16 assets\rasmol.ico

echo Building for Windows...
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DPIXELDEPTH=32
cmake --build build --config Release

echo Packaging MSI...
cd build
cpack -C Release -G WIX
cd ..

echo Build completed successfully.
