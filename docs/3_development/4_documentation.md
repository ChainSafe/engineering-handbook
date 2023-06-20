---
sidebar_position: 4
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

Don't forget to update repository settings as described in [Setup GitHub Repository section](1_development-flow/1_setup_repository.md)

:::

### Deployment

The result of the Docusaurus build step is a static website that can be deployed to
any of the popular hosting services including GitHub Pages, CloudFlare or IPFS.

#### Deploy to CloudFlare Pages

One way to achieve this is by deploying their websites on CloudFlare Pages.

CloudFlare Pages is a modern platform for building and deploying websites. It offers several benefits, including:

- High-performance: CloudFlare Pages uses the same global network as CloudFlare's CDN, which means websites load quickly no matter where the visitor is located.
- Easy to use: Setting up a website on CloudFlare Pages is simple. You can connect your GitHub repository and deploy your site with just a few clicks.
- Security: CloudFlare Pages offers built-in security features such as HTTPS encryption and DDoS protection.

While CloudFlare workers is a relatively inexpensive option for Continuous Deployment, it still has quotas and requires a monthly subscription. On the other hand, GitHub Actions is free for public repositories so it's a preferred way of deploying websites.

Another reason to use GitHub Actions instead of CloudFlare Workers is the visibility of the deployment process in the PR. CloudFlare Worker following the repository changes will attempt to build and deploy the code in the CloudFlare environment and if PR comments for the deployment results are not enabled failure to build or to deploy would be left unnoticed. On the contrary, check, build and deploy steps executed in GitHub Actions not only increase the visibility of the whole process but are also incorporated into the PR approval process.

Here's an example of how you can deploy your website using GitHub Actions:

1. If you don't have access to our Cloudflare account, please reach out to your manager/head of department.
2. Create new Pages project either via CloudFlare Dashboard or [wrangler](https://developers.cloudflare.com/workers/wrangler/install-and-update/)
3. [Generate CloudFlare API Token](https://github.com/cloudflare/pages-action#generate-an-api-token) and add it to the repository secrets under `CLOUDFLARE_API_TOKEN` name.

:::note
You don't need to define `GITHUB_TOKEN` yourself. The workflow-specific token going to be [generated automatically by the GitHub Actions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication).
:::

4. Create a workflow file in their GitHub repository (e.g. .github/workflows/deploy.yml).
5. Add a step to the workflow that deploys the built site to CloudFlare Pages using the CloudFlare Pages API.
6. Set new chainsafe.dev subdomain available inside the "ChainSafeDev" CloudFlare account.

Here's a sample workflow file:

```yaml
name: CloudFlare Deploy
on: 
  push:
    branches:
      - main
  pull_request:
    branches:
      - '**'

permissions:
  contents: read
  deployments: write
  pull-requests: write

jobs:
  deploy:
      runs-on: ubuntu-latest
      if: ${{ github.event.workflow_run.conclusion == 'success' }}
      steps:
          - uses: actions/checkout@v3
          - uses: actions/setup-node@v3
            with:
              cache: yarn
              node-version: '16'
          - run: yarn install --frozen-lockfile
          - run: yarn run build
          - name: Publish to Cloudflare Pages
            uses: cloudflare/pages-action@v1
            with:
              apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
              accountId: 2238a825c5aca59233eab1f221f7aefb
              projectName: <cloudflare project name>
              directory: ./build
              gitHubToken: ${{ secrets.GITHUB_TOKEN }}
```

:::tip
To find PR-specific deployment URL go to the `Actions` tab, select deployment workflow on the left and choose one corresponding to your PR number. The URL will be located in the `deploy summary` section.
:::

#### Deploy to IPFS

WIP

### Additional resources
- <a href="/pages/gitbook-migration" target="_blank">Migrating from GitBook</a>


## Rest API

WIP: Setting up OpenApi repository with https://redocly.com/
