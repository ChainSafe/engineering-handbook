// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/mdx-loader').MDXPlugin} */
// @ts-ignore
const mermaidPlugin = require('mdx-mermaid')

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'ChainSafe Documentation Starter',
  tagline: 'Gophers are cool',
  url: 'https://your-docusaurus-test-site.com',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'throw',
  favicon: 'img/logo.png',
  organizationName: 'ChainSafer', // Usually your GitHub org/user name.
  projectName: 'documentation-starter', // Usually your repo name.

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
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl: 'https://github.com/chainsafe/engineering-wiki/tree/main/',
          remarkPlugins: [
            mermaidPlugin
          ],
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
        title: 'ChainSafe Documentation Starter',
        logo: {
          alt: 'ChainSafe Logo',
          src: 'img/logo.png',
        },
        items: [
          {
            href: 'https://github.com/chainsafe/documentation-starter',
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
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
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
