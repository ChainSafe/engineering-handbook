---
sidebar_position: 3
---

# Documentation

Documentation is crucial tool in achieving ChainSafe's vision to empower
people to create and innovate therefore we should strive for our tools and libraries
to have best documentation possible.

## Libraries and Tools

[Docusaurus 2](https://docusaurus.io/) is used for writing documentation for libraries and tools
because it's open-sourced, highly customizable allows writing documentation in markdown
and we can deploy it everywhere (including IPFS).

### Setup

There is [documentation starter repository](https://github.com/ChainSafe/documentation-starter) with a ChainSafe color scheme which you can use to jump-start your project.
Even though the repository is "Template Repository" I would suggest not to use it as a template as it's going to 
be very hard to pull new changes from the starter repository (because of unrelated git history).
Better way to do it is to choose "Import repository" option and put URL of the starter repository (https://github.com/ChainSafe/documentation-starter).

:::caution

Don't forget to update repository settings as described in [Setup Github Repository section](1_development-flow/1_setup_repository.md)

:::

### Deployment

Result of the Docusaurus build step is a static website that can be deployed to
any of the popular hosting services including Github Pages, Render, Netifly or IPFS.

#### Deploy to Render

Even though using Github Actions is the easiest option, to this date, they don't have Pull Request previews
which make it hard to view changes in the browser. Deploying to [Render](https://render.com/) requires
a one-time setup for which, if you don't have access to ChainSafe's Render account, you can ask your Department Head or DevOps team.

#### Deploy to IPFS

WIP

### Additional resources
- <a href="/pages/gitbook-migration" target="_blank">Migrating from GitBook</a>


## Rest API

WIP: Setting up OpenApi repository with https://redocly.com/