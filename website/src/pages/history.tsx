import type {ReactNode} from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

export default function History(): ReactNode {
  return (
    <Layout
      title="History"
      description="The personal history and development of RasMol by Roger Sayle.">
      <main className="container margin-vert--lg">
        <div className="row">
          <div className="col col--8 col--offset-2">
            <Heading as="h1">The History of RasMol</Heading>
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
              demonstration into a powerful tool capable of rendering wireframes, calculating hydrogen
              bonds, and displaying various molecular representations—often driven by specific requests
              from the research community.
            </p>
            <p>
              In June 1993, Roger released RasMol into the public domain. Despite receiving offers
              of payment, he chose to keep it free, even returning checks from hospitals. A temporary
              position at Glaxo Research and Development eventually turned into a long-term
              arrangement that funded the development of the Apple Macintosh version and provided
              access to a chemistry-oriented user group.
            </p>
            <p>
              Today, RasMol is one of the most widely used molecular graphics programs in the world,
              serving as an essential tool for education and research globally. Roger credits the
              success of RasMol to the user community, whose feedback and suggestions have shaped
              its continual evolution.
            </p>
          </div>
        </div>
      </main>
    </Layout>
  );
}
