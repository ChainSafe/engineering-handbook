# Typescript

Our most notable Typescript stack:
* https://github.com/ChainSafe/lodestar (Ethereum Consensus Client Lodestar)
* https://github.com/ChainSafe/web3.js/tree/4.x (Web3.js)
* https://github.com/ChainSafe/ssz (Simple Serialize library)
* https://github.com/ChainSafe/bls (BLS library)
* https://github.com/ChainSafe/filsnap (Metamask Snap for Filecoin)
* [and others](https://github.com/ChainSafe?q=&type=all&language=typescript&sort=)

## IDE configuration

:::note

TBD

:::

If you need a license for your development tooling, [read on how to request one](../../../5_the-formal-stuff/process_and_policy.md#requesting-license)!

## Project structure

:::note

TBD

:::

### Monorepo

:::note

TBD

:::

## Linting

Linting is a critical step in the source code life cycle. As not everyone in a given team will have the same programming approach, enforced linting rules can help keep a codebase consistent. As linting is a static analysis process, it will catch problems in your coding style, but not the logical errors. 

For example, if one developer uses the `forEach` iterator and another uses the `for` loop, linting rules will give feedback to team members, ensuring they follow a consistent pattern. The same applies to documenting the source code, so it's essential to check that the tools have linting support. 

Recommended lint tool is `eslint` with some chosen plugins (like `prettier` for code formatting) and to ensure code style across ChainSafe, we are providing a [shared configuration](https://github.com/ChainSafe/eslint-config) that you can use in your projects as a baseline:
1. `yarn add --dev eslint@7 @rushstack/eslint-patch @chainsafe/eslint-config` //version depends on version in a shared configuration package.json
   1. You can read more on why `@rushstack/eslint-patch` is needed here: https://github.com/ChainSafe/eslint-config#usage
2. Create `.eslintrc.js` file with the following contents:
```js
require("@rushstack/eslint-patch/modern-module-resolution");

module.exports = {
  extends: "@chainsafe",
}
```
3. add `lint` script in your package.json with command `eslint 'src/**/*.ts'` 

:::note

If you think some rule is missing or unnecessary, feel free to contribute to https://github.com/ChainSafe/eslint-config

:::

## Testing

## Recommended Libraries

:::note

TBD

:::

## Continuous integration

:::note
TBD
:::
