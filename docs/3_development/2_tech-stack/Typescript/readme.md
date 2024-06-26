# Typescript

Our most notable Typescript stack:
* https://github.com/ChainSafe/lodestar (Ethereum Consensus Client Lodestar)
* https://github.com/ChainSafe/web3.js/tree/4.x (Web3.js)
* https://github.com/ChainSafe/ssz (Simple Serialize library)
* https://github.com/ChainSafe/bls (BLS library)
* https://github.com/ChainSafe/filsnap (Metamask Snap for Filecoin)
* [and others](https://github.com/ChainSafe?q=&type=all&language=typescript&sort=)

## IDE configuration

### Visual Studio Code

You can download it here: https://code.visualstudio.com/

It is recommended to install the following extensions:

* [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) - enables highlighting lint errors and fixing them
* [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) - enables advanced git overview
* [DotEnv](https://marketplace.visualstudio.com/items?itemName=mikestead.dotenv) - support for .env files
* [Yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) - support for writing YAML files (useful for GitHub Actions)

:::note
Visual Studio Code already has basic support for Markdown: https://code.visualstudio.com/docs/languages/markdown#_markdown-preview
:::

### Others

If you need a license for your development tooling, [read on how to request one](/the-formal-stuff/process-and-policy#requesting-license)!

## Linting

Linting is a critical step in the source code life cycle. As not everyone in a given team will have the same programming approach, enforced linting rules can help keep a codebase consistent. As linting is a static analysis process, it will catch problems in your coding style, but not the logical errors. 

For example, if one developer uses the `forEach` iterator and another uses the `for` loop, linting rules will give feedback to team members, ensuring they follow a consistent pattern. The same applies to documenting the source code, so it's essential to check that the tools have linting support. 

Recommended lint tool is `eslint` with some chosen plugins (like `prettier` for code formatting) and to ensure code style across ChainSafe, we are providing a [shared configuration](https://github.com/ChainSafe/eslint-config) that you can use in your projects as a baseline:

1. `yarn add --dev eslint@8 @chainsafe/eslint-config` //version depends on version in a shared configuration package.json
2. Create `.eslintrc.js` file with the following contents:

```js

module.exports = {
  extends: "@chainsafe",
}
```

3. add `lint` script in your package.json with command `eslint 'src/**/*.ts'`

:::note

If you think some rule is missing or unnecessary, feel free to contribute to https://github.com/ChainSafe/eslint-config

:::

## Testing

:::note

TBD

:::

## Continuous integration

It is very difficult to develop one-size-fits-all continuous integration, so this is a guideline rather than an actual configuration file. You will see many repositories at ChainSafe modified CI to fit their needs.

You should almost always use GitHub Actions. Consult with your manager if you need to use something else.

```yaml title=".github/workflows/ci.yml"
name: 'ci / test'
on:
  push:
    branches:
      - main # runs on push to master, add more branches if you use them
  pull_request:
    branches:
      - '**' # runs on update to pull request on any branch
jobs:
  # most basic test job
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          cache: 'yarn' # cache node modules
          node-version: lts
      - run: yarn run lint # lint code
      - run: yarn run build # compile typescript into javascript
      - run: yarn run test:unit # run unit tests
      - run: yarn run test:integrations # run integration tests tests

  
  # run on multiple combinations of os and nodejs
  # you should probably consider running checkout and setup-node before it so you cache node modules
  test-matrix:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [windows-latest, ubuntu-latest, macos-latest]
        node: [14, 16]
      fail-fast: true
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        cache: 'yarn' # cache node modules
        node-version: ${{ matrix.node }}
    - run: yarn run lint # lint code
    - run: yarn run build # compile typescript into javascript
    - run: yarn run test:unit # run unit tests
    - run: yarn run test:integrations # run integration tests tests
```

## Releasing npm packages

::: note This is a mostly automated process to enable consistency and make it hassle-free
to release new versions more often
:::
::: caution Make sure the repository is using squash merging and branching rules as described in [Setup repository section](/development/development-flow/setup_repository)!
:::

### Semantic Pull Requests

For automatic releasing and version bumps, you should use semantic Pull Request titles.

Semantic keywords and their meaning:

* **fix** - your PR contains a bugfix which will bump a patch version - Example PR: `fix: resolved bug with automatic releasing`
* **feat** - your PR contains a new feature that will bump a minor version - Example PR: `feat: added a new API endpoint`
* **chore** - your PR contains trivial changes like editing README, bumping packages versions etc - Example PR: `chore: bumped typescript dependency`
* **feat!** or **fix!** (notice exclamation)- your PR contains a breaking change which will trigger a major version update * Example PR: `feat!: new API `endpoint, `the `old`` one is` deprecated`

You can use the following GitHub action to ensure your Pull Requests follow this convention.

```yaml title=".github/workflows/pr.yml"
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
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            fix
            feat
            chore
            revert
```

### Cutting release {#cutting-release}

1. Merge Pull Request with semantic title
2. GitHub Actions will open PR with a version bump in package.json and updated CHANGELOG.md
3. After merging the Release Pull Request, the package will be published on npm and a release with the changelog created on GitHub

Following GitHub action will ensure that the above flow is working.

:::caution

Automatic Pull Request cannot trigger workflow so required status checks cannot pass.
You can either remove the requirement for status checks to pass or set GITHUB_TOKEN to your GitHub PAT token.

:::

```yaml title=".github/workflows/cd.yml"
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
          changelog-types: '[{"type":"feat","section":"Features","hidden":false},{"type":"fix","section":"Bug Fixes","hidden":false},{"type":"chore","section":"Miscellaneous","hidden":true}]'
      
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
          NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}} # use npm "Automation" token and put in GitHub repository secrets under "NPM_TOKEN"
        if: ${{ steps.release.outputs.release_created }}
```

:::note
Feel free to extend this flow with nightly/alpha/beta releases.
:::

#### Reverting

In case of npm publish fails for whatever reason, release-please won't allow you to try to re-run the GitHub action. 
Instead,
you should open the "revert" Pull Request either using GitHub or the local git client.

Before merging it, make sure, you have deleted the git tag and GitHub release upstream.

### Dependabot

Dependabot updates may or may not conform to our semantic rules.
The following configuration should ensure this happens:

```yaml title=".github/.dependabot.yml"
version: 2
updates:
  - package-ecosystem: "yarn"
    schedule:
      interval: daily
    requiredLabels:
      - dependencies
    commit-message:
      prefix: fix
      prefix-development: chore
      include: scope
```
