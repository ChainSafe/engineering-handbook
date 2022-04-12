# Releasing npm packages

:::note
This is mostly automated process to enable consistency and make it hassle free
to release new versions more often
:::

:::caution
Make sure repository is using squash merging and branching rules as described in [Setup repository section](../1_setup_repository.md)!
:::

### Semantic Pull Requests

For automatic releasing and version bumps you should use semantic Pull Request titles.

Semantic keywords and their meaning:
- **fix** - your PR contains bugfix which will bump patch version - Example PR: `fix: resolved bug with automatic releasing`
- **feat** - your PR contains new feature which will bump minor version - Example PR: `feat: added new api endpoint`
- **chore** - your PR contains trivial changes like editing README, bumping packages versions etc. - Example PR: `chore: bumped typescript dependency`
- **feat!** or **fix!** (notice exclamation)- your PR contains breaking change which will trigger major version update - Example PR: `feat!: new api endpoint, old one deprecated`


You can use following github action to ensure your Pull Requests follow this convention.

```yaml title="/.github/workflows/pr.yaml"
name: "Semantic PR"

on:
  pull_request_target:
    types:
      - opened
      - edited
      - synchronize

jobs:
  main:
    name: Validate PR title
    runs-on: ubuntu-latest
    steps:
      - uses: amannn/action-semantic-pull-request@v4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            fix
            feat
            chore
          validateSingleCommit: true #single commit can ovveride squash merge commit message
```

### Cutting release

1. Merge Pull Request with semantic title
2. Github Actions will open PR with version bump in package.json and updated CHANGELOG.md
3. After merging Release Pull Request, package will be published on npm and release with changelog created on github

Following github action will ensure that above flow is working.

```yaml title="/.github/workflows/cd.yaml"
name: Release
on:
  push:
    branches:
      - main
jobs:
  maybe-release:
    name: release
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
        # you should probably do this after your regular CI checks passes
      - uses: google-github-actions/release-please-action@v3 # it will analyze commits and create PR with new version and updated CHANGELOG:md file. On merging it will create github release page with changelog
        id: release
        with:
          release-type: node
          package-name: release-please-action
          changelog-types: '[{"type":"feat","section":"Features","hidden":false},{"type":"fix","section":"Bug Fixes","hidden":false},{"type":"chore","section":"Miscellaneous","hidden":false}]'
      
      - uses: actions/checkout@v3
        # these if statements ensure that a publication only occurs when
        # a new release is created:
        if: ${{ steps.release.outputs.release_created }}
        
      - uses: actions/setup-node@v3
        with:
          cache: 'yarn'
          node-version: 16
          registry-url: 'https://registry.npmjs.org'
        if: ${{ steps.release.outputs.release_created }}
      
      - run: yarn install --ignore-scripts
        if: ${{ steps.release.outputs.release_created }}
      
      - run: yarn build
        if: ${{ steps.release.outputs.release_created }}

      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}} # use npm "Automation" token and put in Github repository secrets under "NPM_TOKEN"
        if: ${{ steps.release.outputs.release_created }}
```

:::note
Feel free to extend this flow with nightly/alpha/beta releases.
:::

### Dependabot

Dependabot updates may or may not conform to our semantic rules.
Following configuration should ensure this happens:

```yaml title=".github/.dependabot.yaml"
version: 2
updates:
  - package-ecosystem: "yarn"
    allow:
      # Allow both direct and indirect updates for all packages
      - dependency-type: "production"
    commit-message:
      prefix: "chore: "
```