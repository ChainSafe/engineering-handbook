// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const {themes} = require('prism-react-renderer');

/** @type {import('@docusaurus/mdx-loader').MDXPlugin} */
// @ts-ignore
const mermaidPlugin = require('mdx-mermaid')

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'ChainSafe Engineering Handbook',
  tagline: 'Gophers are cool',
  url: 'https://your-docusaurus-test-site.com',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'throw',
  favicon: 'img/logo.png',
  organizationName: 'ChainSafer', // Usually your GitHub org/user name.
  projectName: 'engineering-wiki', // Usually your repo name.

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        blog: false,
        debug: true,
        pages: {
          routeBasePath: '/pages'
        },
        docs: {
          routeBasePath: '/',
          // routeBasePath: '/',
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl: 'https://github.com/chainsafe/engineering-handbook/tree/main/',
          remarkPlugins: [mermaidPlugin],
        },
        theme: {
          customCss: require.resolve('./src/css/index.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        defaultMode: 'dark',
        disableSwitch: true,
        respectPrefersColorScheme: false,
      },
      navbar: {
        title: 'ChainSafe Engineering Handbook',
        logo: {
          alt: 'ChainSafe Logo',
          src: 'img/logo.png',
        },
        items: [
          {
            href: 'https://github.com/chainsafe/engineering-wiki',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [],
        copyright: `Copyright © ${new Date().getFullYear()} ChainSafe. Built with Docusaurus.`,
      },
      prism: {
        darkTheme: themes.dracula,
      }
    }),
    plugins: [
      [
        require.resolve("@cmfcmf/docusaurus-search-local"),
        {
          indexBlog: false,
          indexPages: false,
          indexDocs: true,
        },
      ],
    ],
};

module.exports = config;
