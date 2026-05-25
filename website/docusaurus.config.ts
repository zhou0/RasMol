import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'RasMol',
  tagline: 'Molecular Graphics Visualization',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://zhou0.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'zhou0', // Usually your GitHub org/user name.
  projectName: 'RasMol', // Usually your repo name.
  trailingSlash: false,

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl:
            'https://github.com/zhou0/RasMol/tree/main/website/',
        },
        blog: {
          showReadingTime: true,
          feedOptions: {
            type: ['rss', 'atom'],
            xslt: true,
          },
          editUrl:
            'https://github.com/zhou0/RasMol/tree/main/website/',
          onInlineTags: 'warn',
          onInlineAuthors: 'warn',
          onUntruncatedBlogPosts: 'warn',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/rasmol-social-card.jpg',
    navbar: {
      title: 'RasMol',
      logo: {
        alt: 'RasMol Logo',
        src: 'img/rasmol-logo.svg',
      },
      items: [
        {to: '/bibliography', label: 'Bibliography', position: 'left'},
        {to: '/download', label: 'Download', position: 'left'},
        {to: '/features', label: 'Features', position: 'left'},
        {to: '/history', label: 'History', position: 'left'},
        {to: '/legacydocs', label: 'Legacy Docs', position: 'left'},
        {to: '/blog', label: 'Blog', position: 'left'},
        {
          href: 'https://github.com/zhou0/RasMol',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Bibliography',
              to: '/bibliography',
            },
            {
              label: 'Legacy Docs',
              to: '/legacydocs',
            },
          ],
        },
        {
          title: 'Legacy Project Site',
          items: [
            {
              label: 'OpenRasMol',
              href: 'https://sourceforge.net/projects/openrasmol',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Blog',
              to: '/blog',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/zhou0/RasMol',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} RasMol Project. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
