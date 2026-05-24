   changes from the 2.7.3.1 release to the 2.7.4.1 release included:
     * Support for maps.
     * Message and menu translations for Russian, Bulgarian, Japanese and
       Chinese. Our thanks to G. Pozhvanov, G. Todorov, Nan Jia, Mamoru
       Yamanishi and Katajima Hajime.
     * Fix torsion angle calculation as per bug report and patch by Swati
       Jain.
     * Corrections by Ladislav Michnovic to port to more platforms.
     * Code to read remediated PDB entries as suggested by Huanwang Yang
     * Updated icons.
     * Extended export menus.
   For more detail on these and earlier changes, consult the openrasmol svn
   repository on sourceforge.

   This version is available for MS Windows and various unix-systems. As
   binaries become available, they will be released on
   http://blondie.dowling.edu/projects/rasmol and
   http:/www.sourceforge.net/projects/openrasmol.

   For installation instructions see "INSTALL".

   For a list of open issues in this version, see "TODO".

   RasMol is a molecular graphics program intended for the visualisation of
   proteins, nucleic acids and small molecules. The program is aimed at
   display, teaching and generation of publication quality images. The
   original program was been developed at the University of Edinburgh's
   Biocomputing Research Unit and the Biomolecular Structures Group at Glaxo
   Research and Development, Greenford, UK.

   RasMol reads in molecular co-ordinate files in a number of formats and
   interactively displays the molecule on the screen in a variety of colour
   schemes and representations. Currently supported input file formats
   include Brookhaven Protein Databank (PDB), Tripos' Alchemy and Sybyl Mol2
   formats, Molecular Design Limited's (MDL) Mol file format, Minnesota
   Supercomputer Center's (MSC) XMol XYZ format, CHARMm format, MOPAC format,
   CIF format and mmCIF format files. If connectivity information and/or
   secondary structure information is not contained in the file this is
   calculated automatically. The loaded molecule may be shown as wireframe,
   cylinder (drieding) stick bonds, alpha-carbon trace, spacefilling (CPK)
   spheres, macromolecular ribbons (either smooth shaded solid ribbons or
   parallel strands), hydrogen bonding and dot surface. Atoms may also be
   labelled with arbitrary text strings. Alternate conformers and multiple
   NMR models may be specially coloured and identified in atom labels.
   Different parts of the molecule may be displayed and coloured
   independently of the rest of the molecule or shown in different
   representations simultaneously. The space filling spheres can even be
   shadowed. The displayed molecule may be rotated, translated, zoomed,
   z-clipped (slabbed) interactively using either the mouse, the scroll bars,
   the command line or an attached dials box. RasMol can read a prepared list
   of commands from a `script' file (or via interprocess communication) to
   allow a given image or viewpoint to be restored quickly. RasMol can also
   create a script file containing the commands required to regenerate the
   current image. Finally the rendered image may be written out in a variety
   of formats including both raster and vector PostScript, GIF, PPM, BMP,
   PICT, Sun rasterfile or as a MolScript input script or Kinemage.

   Versions of RasMol have run on a wide range of architectures and systems
   including SGI, sun4, sun3, sun386i, SGI, DEC, HP and E&S workstations, IBM
   RS/6000, Cray, Sequent, DEC Alpha (OSF/1, OpenVMS and Windows NT), IBM PC
   (under Microsoft Windows, Windows NT, OS/2, Linux, BSD386 and *BSD), Apple
   Macintosh (System 7.0 or later), PowerMac and VAX VMS (under DEC Windows).
   UNIX and VMS versions require an 8bit, 24bit or 32bit X Windows frame
   buffer (X11R4 or later). The X Windows version of RasMol provides optional
   support for a hardware dials box and accelerated shared memory rendering
   (via the XInput and MIT-SHM extensions) if available.

   Reports of builds and/or problems on various platforms appreciated.

     ----------------------------------------------------------------------

                            Source Code and Binaries

   The complete source code and user documentation of RasMol 2.7.5.2 may be
   obtained http://www.sourceforge.net/projects/rasmol. and by anonymous FTP
   at:

   ftp://ftp.bernstein-plus-sons.com/software/RasMol_2.7.5.2.tar.gz

   or on the web at:

   http://www.bernstein-plus-sons.com/software/RasMol_2.7.5.2.tar.gz

   http://www.sourceforge.net/projects/rasmol.

     Any comments, suggestions or questions about this modified version of
          RasMol should be directed to rasmol@bernstein-plus-sons.com.

| OpenRasMol | Copying and Distribution | Contents | Installation Instructions |
      | Changes | Things To Do | Introduction | Source Code and Binaries |
| RasMol Manual | Spanish Translation of RasMol Manual | Italian Translation of
                            RasMol 2.7.1 Help File |
      | Donate to Support RasMol | Release README | Register your RasMol |

     ----------------------------------------------------------------------

                              Updated 14 May 2011.
                              Herbert J. Bernstein
        Bernstein + Sons, 5 Brewster Lane, Bellport, NY 11713-2803, USA
                          yaya@bernstein-plus-sons.com
