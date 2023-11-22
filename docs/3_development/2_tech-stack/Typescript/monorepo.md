# Monorepo

:::note

At ChainSafe, we used to use `lerna` to manage our monorepos. 
It was not ideal but it got the job done. Since `lerna` is being [taken over by nx](https://github.com/lerna/lerna/issues/3121) and her future is not really clear, we decided to switch to `yarn 3` and its workspaces.

:::
## Template

:::note

Template is currently in WIP state.

:::


To speedup setting up monorepo you can use [yarn workspaces typescript template](https://github.com/ChainSafe/yarn-workspaces-typescript-template)  
For manual setup or to understate what is all inside template go to **Setup** section


## Setup

### 1. Corepack

If you are running node@16+, you just need to run `corepack enable`.
If you are running older version, run `npm i -g corepack`.
Make sure you put this in README file for future contributors.

:::warning

Date: 22 November 2023
There is an issue with `actions/setup-node@v3` it is used with `cache: 'yarn'`

:::

### 2. Init repository

- Make sure your root `package.json` contains:

```json
  "packageManager": "yarn@3.4.1",
  "workspaces": [
    "packages/*"
  ],
```

- Create `.yarnrc.yml` file with following content:

```yaml
# size of cache is not concern if you aren't using zero-installs
compressionLevel: 0

enableGlobalCache: true

nmMode: hardlinks-local

nodeLinker: node-modules
```

- Make sure your `.gitignore` file contains:

```txt
node_modules
*DS_Store
.idea
.vscode
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/sdks
!.yarn/versions
```

You can check out the [FilSnap repository](https://github.com/chainsafe/filsnap) as an example of such a setup.

## Publishing

After you [update your versions in](#updating-monorepo-versions) `package.json` files,
you can publish all packages by running `yarn workspaces foreach -v --exclude root npm publish --access public`

or in GitHub Actions:

```yaml
     - env:
          NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}}
        if: ${{ steps.release.outputs.releases_created }}
        run: |
          echo npmAuthToken: "$NODE_AUTH_TOKEN" >> ./.yarnrc.yml
          
    - run: yarn workspaces foreach -v --exclude root npm publish --access public
      if: ${{ steps.release.outputs.releases_created }}
```

## Caveats

### Recursiveness

Let's say you have the following scripts in your root `package.json`:

```json title="package.json"
{
  "scripts": {
    "build": "yarn run build:local",
    "build:local": "yarn workspaces foreach -vpt run build"
  }
}
```
:::note

TBD

:::

which you can fix by adding `--exclude root` or by changing build to `yarn workspaces foreach -vpt run build` instead of invoking another script.


### Updating yarn version

Since your yarn version is checked into your GitHub repository it will be consistent across all contributors.
But that also means you need to update it manually every now and then to stay up-to-date.

### Checksum mismatch

This might be only temporary but `yarn` has some weird bug where git dependencies are packed (instead of used as it in v1)
and their checksum is not the same on all operating systems.

An ideal way to fix this is something like this:
```json title="package.json"
{
  "resolutions": {
    "web3/bignumber.js": "2.0.8",
    "ethereumjs-abi": "0.6.8"
  }
}
```

This would force usage of the `bignumber.js`, in the `web3` dependency only, to npm version rather than git commit or `ethereumjs-abi` everywhere.

If you cannot do it you can put `checksumBehavior: "update"` in your `.yarnrc` file.

## Migration from Lerna

1. Run `corepack enable`
2. Add `"packageManager": "yarn@3.2.3"` to your package.json (make sure to use latest version)
3. If you used `.npmrc` or `.yarnrc`, you'll need to turn them into [the new format](https://yarnpkg.com/configuration/yarnrc)
4. Add following to your `.yarnrc.yml` file:
```yaml title=".yarnrc.yml"
# size of cache is not concern if you aren't using zero-installs
compressionLevel: 0

enableGlobalCache: true

nmMode: hardlinks-local

nodeLinker: node-modules
```
5. Commit the changes so far (package.json, .yarnrc.yml, ...)
6. Run `yarn install` to migrate the lockfile
7. Add the following to `.gitignore`:
``` title=".gitignore"
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/sdks
!.yarn/versions
```
8. Install the following plugins:
```bash
yarn plugin import interactive-tools
yarn plugin import workspace-tools
yarn plugin import typescript
yarn plugin import https://raw.githubusercontent.com/devoto13/yarn-plugin-engines/main/bundles/%40yarnpkg/plugin-engines.js
```
9. Delete `lerna.json` and remove `lerna` dependency
10. Add the following to package.json
```json title="package.json"
"private": true,
"workspaces": [
    "packages/*"
],
```
11. In `package.json` scripts:
    1.  replace `lerna run <command>` with `yarn workspaces foreach -vpt run <command>`
    2.  replace `lerna run --scope <pkg> <command>` with `yarn workspace <pkg> <command>`
12. Set packages that depend on each other to `"@chainsafe/pkgB": "workspace:^"` - this will force using local packages and will be replaced with a version before publishing
13. Don't forget to do changes in CI if necessary
14. Run `yarn` again to update a lockfile
15. Commit everything

### Updating monorepo versions

To enable version commands, you need to install the version plugin:
`yarn plugin import version`

Make sure to read more about the new workspace resolution option: https://yarnpkg.com/features/workspaces#workspace-ranges-workspace

#### Independent versioning
If you track versions of your package independently, 
you can use `yarn workspace workspace-1 version -i <major|minor|patch|semver range>`
but it's probably better to automate this using [release please](./#cutting-release)

#### Uniform versioning

If, on the other hand, you view all your monorepo packages as one cohesive unit with an exact version across the board, you can use the following command to update versions: `yarn workspaces foreach -v version -i 5.0.0`.
