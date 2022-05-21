---
id: gitbook
title: Gitbook migration
hide_table_of_contents: false
---

# Gitbook migration

This guide describes the process of converting Gitbook docs into Docusarus.
Luckily, they are both using Markdown to render content, which makes the process a bit easier.


## 1. Setup Docusaurus Repository

Start by selecting "Import repository" option in Github and put the URL of the starter repository (https://github.com/ChainSafe/documentation-starter). Update `docusaurus.config.js` and `package.json` configs with proper naming and urls. 

## 2. Export Gitbook Docs to Markdown

You can do this by syncing the Gitbook site with Github.
Choose the 3 dots icon in the top-right corner of your Gitbook site and choose the "Synchronize with Github" option.
Connect your Github account if you haven't already and select a Github repository where you want your Gitbook site to export. **Make sure there are no branch protection rules in place and that priority is selected "Gitbook to Github".**

![./assets/sync-with-github.png](./assets/sync-with-github.png)

## 3. Migrate content

Copy all `.md` files from exported Github repository into your new Docusarus repository into `/docs` directory.
Delete `SUMMARY.md` file because in Docosaurus it is automatically generated (Read more how to modify sidebar: https://docusaurus.io/docs/sidebar/autogenerated#autogenerated-sidebar-metadata).

If you ran `yarn start` in the new repository you should see your documentation homepage. There will probably be some unsupported markdown features.

## 4. Fix unsupported Markdown features

### Embedded Video or Playlist links

| Gitbook | Docusaurus |
| --- | --- |
| `{% embed url="<youtube video url>" %}` |  Go to the source (Youtube, Vimeo), choose to share embedded and paste raw html code in markdown |

### Change anchor names

| Gitbook | Docusaurus |
| --- | --- |
| `# Heading <a href="#heading2" id="heading2"></a>` |  `# Heading {#heading2}` |