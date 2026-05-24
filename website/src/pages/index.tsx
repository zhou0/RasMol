import type {ReactNode} from 'react';
import clsx from 'clsx';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Welcome to ${siteConfig.title}`}
      description="RasMol is a molecular graphics program for the visualisation of proteins, nucleic acids and small molecules.">
      <HomepageHeader />
      <main>
        <section className={styles.features}>
          <div className="container">
            <div className="row">
              <div className={clsx('col col--8 col--offset-2')}>
                <div className="text--center padding-horiz--md">
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
