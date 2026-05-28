import type {ReactNode} from 'react';
import clsx from 'clsx';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Welcome to ${siteConfig.title}`}
      description="RasMol is a molecular graphics program for the visualisation of proteins, nucleic acids and small molecules.">
      <main>
        <section className={styles.features}>
          <div className="container">
            <div className="row">
              <div className={clsx('col col--8 col--offset-2')}>
                <div className="text--left padding-horiz--md">
                  <Heading as="h2">Introduction to RasMol</Heading>
                  <p>
                    RasMol is a molecular graphics program intended for the visualisation of proteins,
                    nucleic acids and small molecules. The program is aimed at display, teaching and
                    generation of publication quality images. Originally developed by Roger Sayle,
                    RasMol has become a standard tool in structural biology.
                  </p>
                  <p>
                    The software interactively displays molecules in various representations such as
                    wireframe, sticks, and spacefilling spheres. It handles a vast array of file
                    formats, including PDB and CIF, and allows for precise control over coloring and
                    viewing angles.
                  </p>
                  <p>
                    The OpenRasMol project, the long-standing official repository for RasMol development,
                    has been largely inactive since 2012. This current project has been initiated to
                    modernize the codebase and ensure that RasMol continues to serve the needs of the
                    scientific community in the years to come.
                  </p>
                  <p>
                    Whether you are a researcher analyzing protein-ligand interactions or a student
                    learning about molecular architecture, RasMol provides the speed and flexibility
                    needed to explore the microscopic world.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
