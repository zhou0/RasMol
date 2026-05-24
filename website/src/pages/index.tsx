import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
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
        <div className={styles.buttons}>
          <a
            className="button button--secondary button--lg"
            href="pathname:///legacy/">
            View Legacy Documentation
          </a>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description="The personal history and development of RasMol by Roger Sayle.">
      <HomepageHeader />
      <main>
        <section className={styles.features}>
          <div className="container">
            <div className="row">
              <div className={clsx('col col--8 col--offset-2')}>
                <div className="text--center padding-horiz--md">
                  <Heading as="h2">The History of RasMol</Heading>
                  <p>
                    RasMol (RASter MOLecules) was born in 1989 as a final-year parallel programming project by
                    Roger Sayle at Imperial College, London. At the time, biochemistry was shifting its
                    emphasis from simple connectivity to complex surfaces and interactions, which required
                    better depth perception through shadowing and real-time manipulation. Roger chose
                    spheres as the primary graphical object and spent his project comparing algorithms
                    to speed up ray-tracing on parallel computers.
                  </p>
                  <p>
                    While pursuing a PhD at the University of Edinburgh, Roger met Dr. Andrew Coulson, who
                    became a mentor for RasMol. Over the next four years, the program evolved from a simple
                    demonstration that rotated a picture of crambin into a powerful tool capable of
                    rendering wireframes, calculating hydrogen bonds, and displaying various molecular
                    representations—often driven by specific requests from the research community.
                  </p>
                  <p>
                    In June 1993, Roger released RasMol (for UNIX and PC) into the public domain. Despite
                    receiving offers of payment, he chose to keep it free, even returning checks from
                    hospitals. A temporary position at Glaxo Research and Development eventually turned into
                    a long-term arrangement that funded the development of the Apple Macintosh version and
                    provided access to a chemistry-oriented user group.
                  </p>
                  <p>
                    Today, RasMol is one of the most widely used molecular graphics programs in the world,
                    serving as an essential tool for education and research in both developed and
                    under-developed countries. Roger credits the real success of RasMol to the user community,
                    whose feedback, bug reports, and suggestions have shaped its continual evolution.
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
