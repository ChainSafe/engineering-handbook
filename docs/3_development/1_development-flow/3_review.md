---
sidebar_position: 3
---
# Peer Review

:::note
Document everything, communicate with your team transparently, review together.
:::

## Documentation

- Ensure readability is retained in code eg. complex nested ternary operators should have a comment note
- Ensure adequate testing exists where needed
- PRs include a summary of work which outlines the objectives, decisions & considerations for the PR. Examples:
    - This PR's objective was to implement middleware for logging, this was completed however presentation & storage of logs is incomplete pending discussion. Certain components are outside of the logging scope at the moment.
    - This PR includes minor styling tweaks on the desktop & mobile navigation menus, refactored navigation list logic.

## Communication

Ask a team mate on the relevant team channel for a review, this ensures the request is clear as well as gives transparency to the rest of your team if commentary or considerations need to be made.

## Walkthroughs

Walkthroughs is peer programming for reviews, if possible/required, ask for a walkthrough if your teammate has capacity, reviewing together allows you to share context to your work with your reviewer.

## Requesting Reviews

If a project isn't setup with [codeowners](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners) when you open a pull request, and mark it ready for review, you'll need to get your peers to review it. Every repository should have two different Github teams added to it (at minimum): `project_name-admins` and `project_name`, request the **non admin** team for review will allow your whole team to receive a notification about your new pull request.

## Changelog

Assuming your project has releases, and is continually making updates, the project will need a changelog. When submitting a pr make sure to update the changelog reflecting the changes that your PR is making. This way, when a new release is made, there is already a changelog ready to go and no extra work is needed.