# RasMol: Molecular Graphics Visualization

RasMol is a molecular graphics program for visualising proteins, nucleic acids, and small molecules. Originally developed at the University of Edinburgh, it supports numerous formats like PDB, CIF, and MDL Mol.

## Modern Updates
The project now features a modern **CMake-based build system** supporting Unix and Windows (MSVC). A new **themed Tcl/Tk user interface** (ttk) is available in `gui/tcltk/`, integrated via a C bridge in `warpings/tcl/`. Optional **VTK 9.3.1 integration** provides an advanced OpenGL rendering mode.

## Building
Configure and build with CMake:
```bash
cmake -B build -S .
cmake --build build
```
Launch `rasmol_tcl` for the themed UI.

## License
Version based on 2.7.5.2. Distributed under GPL or RASLIC. See `doc/NOTICE.html` for details.
