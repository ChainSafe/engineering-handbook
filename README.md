# ChainSafe Engineering Handbook

This handbook is a guide for all engineers at ChainSafe. It contains content relating to organizational structure and processes, as well as technical guidelines and best practices.

The handbook is built using [Docusaurus 2](https://docusaurus.io/), a modern static docs generator.

# Dependencies

This project requires `yarn`. You can find installation instructions [here](https://yarnpkg.com/getting-started/install).

# Running Locally

Fetch project dependencies:
```
$ yarn
```
Start development server:
```
$ yarn start
```

This command starts a local development server (localhost:3000) and opens up a browser window. Most changes are reflected live without having to restart the server.

# Spellcheck
```
yarn spellcheck
```
You can add unknown words to `dictionary.txt`.

# Building

```
$ yarn build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

# Contributing

All contributions are welcomed! This is intended to be a living document and requires contributions of many to be maintained.

Please use Github Issues to propose any large changes and to facilitate discussion and questions regarding content and structure.

It is recommended you review the [Docusaurus docs](https://docusaurus.io/docs) to ensure you utilize its features correctly.

# Project Structure

`docs/` -- The handbook content lives here, separated by sections

`src/` -- Individual page assets 

`static/` -- Web-ready assets such as icons (will not be bundled with webpack)

