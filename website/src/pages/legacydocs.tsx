import type {ReactNode} from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

export default function LegacyDocs(): ReactNode {
  return (
    <Layout
      title="Legacy Documentation"
      description="Download legacy RasMol documentation in PDF format.">
      <main className="container margin-vert--lg">
        <div className="row">
          <div className="col col--8 col--offset-2">
            <Heading as="h1">Legacy PDF Documentation</Heading>
            <p>
              The following documents provide legacy documentation for RasMol in PDF format.
              These include the full User Manual and the Reference Card in both A4 and US Letter sizes.
            </p>
            <p>
              <em>Note: These documents are for older versions of RasMol and are provided for historical reference.</em>
            </p>

            <section className="margin-vert--lg">
              <Heading as="h2">User Manuals</Heading>
              <ul>
                <li className="margin-bottom--md">
                  <strong>RasMol User Manual (A4)</strong><br />
                  Full documentation formatted for A4 paper.<br />
                  <a className="button button--secondary button--sm margin-top--xs" href="/pdf/manualA4.pdf" target="_blank">Download PDF</a>
                </li>
                <li className="margin-bottom--md">
                  <strong>RasMol User Manual (US Letter)</strong><br />
                  Full documentation formatted for US Letter paper.<br />
                  <a className="button button--secondary button--sm margin-top--xs" href="/pdf/manualUS.pdf" target="_blank">Download PDF</a>
                </li>
              </ul>
            </section>

            <section className="margin-vert--lg">
              <Heading as="h2">Reference Cards</Heading>
              <ul>
                <li className="margin-bottom--md">
                  <strong>RasMol Reference Card (A4)</strong><br />
                  Quick reference guide formatted for A4 paper.<br />
                  <a className="button button--secondary button--sm margin-top--xs" href="/pdf/refcardA4.pdf" target="_blank">Download PDF</a>
                </li>
                <li className="margin-bottom--md">
                  <strong>RasMol Reference Card (US Letter)</strong><br />
                  Quick reference guide formatted for US Letter paper.<br />
                  <a className="button button--secondary button--sm margin-top--xs" href="/pdf/refcardUS.pdf" target="_blank">Download PDF</a>
                </li>
              </ul>
            </section>
          </div>
        </div>
      </main>
    </Layout>
  );
}
