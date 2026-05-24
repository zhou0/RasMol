import type {ReactNode} from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

export default function Features(): ReactNode {
  return (
    <Layout
      title="Features"
      description="Key features and capabilities of RasMol 2.7.">
      <main className="container margin-vert--lg">
        <div className="row">
          <div className="col col--8 col--offset-2">
            <Heading as="h1">RasMol Features</Heading>
            <p>
              RasMol is a powerful molecular graphics program designed for the visualization of
              proteins, nucleic acids, and small molecules. Its key features include:
            </p>
            <ul>
              <li><strong>Broad Format Support:</strong> Reads PDB, Alchemy, Sybyl Mol2, MDL Mol, XYZ, CHARMm, MOPAC, and (mm)CIF formats.</li>
              <li><strong>Interactive Visualization:</strong> Real-time rotation, translation, and zooming via mouse, command line, or dials.</li>
              <li><strong>Multiple Representations:</strong> Wireframe, sticks, spacefilling (CPK) spheres, ribbons (solid or strands), alpha-carbon traces, and dot surfaces.</li>
              <li><strong>Advanced Coloring Schemes:</strong> Color by atom type, residue, temperature factor, or secondary structure.</li>
              <li><strong>Shadowing and Slicing:</strong> High-quality rendering with shadowing and interactive Z-clipping (slabbing).</li>
              <li><strong>Scripting Capability:</strong> Load scripts to restore viewpoints or export the current state as a script file.</li>
              <li><strong>Export Options:</strong> Save images as PostScript, GIF, PPM, BMP, PICT, Sun rasterfile, or as MolScript/Kinemage inputs.</li>
              <li><strong>Educational Tool:</strong> Widely used in teaching to demonstrate molecular symmetry, bonding, and structure.</li>
            </ul>
            <p>
              RasMol's efficiency allows it to run on a wide range of hardware, from high-end
              workstations to standard personal computers, making it accessible for researchers
              and students worldwide.
            </p>
          </div>
        </div>
      </main>
    </Layout>
  );
}
