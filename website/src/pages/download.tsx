import React, { useEffect, useState } from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

interface Asset {
  id: number;
  name: string;
  browser_download_url: string;
}

interface Release {
  id: number;
  name: string;
  tag_name: string;
  published_at: string;
  html_url: string;
  assets: Asset[];
  body: string;
}

export default function Download() {
  const [releases, setReleases] = useState<Release[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch('https://api.github.com/repos/zhou0/RasMol/releases')
      .then(response => {
        if (!response.ok) {
          throw new Error('Failed to fetch releases');
        }
        return response.json();
      })
      .then(data => {
        setReleases(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  return (
    <Layout title="Download" description="Download the latest version of RasMol">
      <main className="container margin-vert--lg">
        <Heading as="h1">Downloads</Heading>
        <p>This page automatically displays all releases from our GitHub repository.</p>

        {loading && <p>Loading releases...</p>}
        {error && <p className="alert alert--danger">Error: {error}</p>}

        {!loading && !error && releases.length === 0 && <p>No releases found.</p>}

        {releases.map(release => (
          <section key={release.id} className="margin-bottom--xl">
            <div className="card">
              <div className="card__header">
                <Heading as="h2">
                  <a href={release.html_url} target="_blank" rel="noopener noreferrer">
                    {release.name || release.tag_name}
                  </a>
                </Heading>
                <small>{new Date(release.published_at).toLocaleDateString()}</small>
              </div>
              <div className="card__body">
                <h3>Assets</h3>
                <ul>
                  {release.assets.map(asset => (
                    <li key={asset.id}>
                      <a href={asset.browser_download_url} target="_blank" rel="noopener noreferrer">
                        {asset.name}
                      </a>
                    </li>
                  ))}
                </ul>
                {release.assets.length === 0 && <p>No direct download assets available for this release.</p>}
              </div>
              <div className="card__footer">
                <a className="button button--primary" href={release.html_url} target="_blank" rel="noopener noreferrer">
                  View Release on GitHub
                </a>
              </div>
            </div>
          </section>
        ))}
      </main>
    </Layout>
  );
}
