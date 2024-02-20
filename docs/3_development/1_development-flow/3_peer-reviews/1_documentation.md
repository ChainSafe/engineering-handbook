---
sidebar_position: 3
---
# Documentation

:::note
Document everything, communicate with your team transparently, review together.
:::

- Ensure readability is retained in code e.g. complex nested ternary operators should have a comment note
- Ensure [adequate testing](/development/quality_assurance/manual-test-case-guidelines) exists where needed
- Code change requests include a summary of work which outlines the objectives, decisions & considerations for the code change. Examples:
    - This PR's objective was to implement middleware for logging, this was completed however presentation & storage of logs is incomplete pending discussion. Certain components are outside the logging scope at the moment.
    - This PR includes minor styling tweaks on the desktop & mobile navigation menus, refactored navigation list logic.
    - or simply add a [PR template](https://github.com/ChainSafe/engineering-handbook/blob/main/.github/PULL_REQUEST_TEMPLATE.md) with a description and issue reference
