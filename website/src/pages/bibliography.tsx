import type {ReactNode} from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

export default function Bibliography(): ReactNode {
  return (
    <Layout
      title="Bibliography"
      description="Bibliography of papers related to RasMol.">
      <main className="container margin-vert--lg">
        <div className="row">
          <div className="col col--8 col--offset-2">
            <Heading as="h1">Bibliography</Heading>

            <section className="margin-vert--lg">
              <Heading as="h2">RasMol: A program for fast realistic rendering of molecular structures with shadows</Heading>
              <p>
                <strong>Authors:</strong> Roger Sayle and Andrew Bissell<br />
                <strong>Booktitle:</strong> Proceedings of the 10th Eurographics UK<br />
                <strong>Volume:</strong> 92<br />
                <strong>Pages:</strong> 7--9<br />
                <strong>Year:</strong> 1992<br />
                <strong>Organization:</strong> sn
              </p>
              <a
                className="button button--primary"
                href="/pdf/RasMol_A_program_for_fast_realistic_rendering_of_molecular_structures_with_shadows.pdf"
                target="_blank"
                rel="noopener noreferrer">
                Download PDF
              </a>
            </section>

            <hr />

            <section className="margin-vert--lg">
              <Heading as="h2">Recent changes to RasMol, recombining the variants</Heading>
              <p>
                <strong>Author:</strong> Herbert J. Bernstein<br />
                <strong>Journal:</strong> Trends in biochemical sciences<br />
                <strong>Volume:</strong> 25<br />
                <strong>Number:</strong> 9<br />
                <strong>Pages:</strong> 453--455<br />
                <strong>Year:</strong> 2000<br />
                <strong>Publisher:</strong> Elsevier
              </p>
              <a
                className="button button--primary"
                href="/pdf/Recent_changes_to_RasMol_recombining_the_variants.pdf"
                target="_blank"
                rel="noopener noreferrer">
                Download PDF
              </a>
            </section>
          </div>
        </div>
      </main>
    </Layout>
  );
}
