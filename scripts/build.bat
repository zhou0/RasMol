@echo off
setlocal

:: Determine project root
set SCRIPT_DIR=%~dp0
cd /d %SCRIPT_DIR%..

echo Checking dependencies...
where choco >nul 2>&1
if %errorlevel% == 0 (
    echo Installing dependencies via Chocolatey...
    choco install imagemagick -y
    choco install magicsplat-tcl-tk --version=1.16.0 -y
) else (
    echo Warning: Chocolatey not found. Skipping automatic dependency installation.
)

echo Preparing icons for Windows...
set SVG_PATH=website\static\img\rasmol-logo.svg
if not exist build\assets mkdir build\assets

where magick >nul 2>&1
if %errorlevel% == 0 (
    echo Generating icon from SVG using ImageMagick (magick)...
    magick -background none %SVG_PATH% -define icon:auto-resize=256,128,64,48,32,16 build\assets\rasmol.ico
) else (
    where convert >nul 2>&1
    if %errorlevel% == 0 (
        echo Generating icon from SVG using ImageMagick (convert)...
        convert -background none %SVG_PATH% -define icon:auto-resize=256,128,64,48,32,16 build\assets\rasmol.ico
    ) else (
        echo Warning: ImageMagick (magick/convert) not found. Using fallback legacy icon.
        if exist src\mswin\raswin.ico (
            copy src\mswin\raswin.ico build\assets\rasmol.ico >nul
        ) else (
            echo Error: Fallback icon src\mswin\raswin.ico not found!
        )
    )
)

echo Building for Windows...
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DPIXELDEPTH=32
cmake --build build --config Release

echo Packaging MSI...
cd build
cpack -C Release -G WIX
cd ..

echo Build completed successfully.
