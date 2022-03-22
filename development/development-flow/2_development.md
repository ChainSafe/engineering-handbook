# Development

<aside>
    🚨 If a repository is owned by ChainSafe there is no reason to fork the repository for pull requests.
</aside>

<aside>
    🚨  The default branch should be `main`. For the majority of the time, pull requests will be merged into the `main` branch.
</aside>


# 1. Create a branch off of `main`

### Personal Branches

Should follow the format `<name>/<feature>` for example: `greg/create-readme`. You can use your username, or some other unique identifier, but please keep it consistent. The reason for this, is that git stores branches in this format, when it views a `/` its assumed to be a directory. Thus when you look at a git project `.git/refs/heads` you will see everyone has their own folder with their branches!

### Release Branches

When making a release, a corresponding tag should be created using git ex: `git tag v0.23.1-rc`. In the case where a previous build needs to be back ported, a release branch should be created with the prefix `release` and the corresponding version number eg: `release/v0.23.1-rc`.


# 2. Opening a PR (Pull Request) on Github

When opening a pull request there are two types that can be opened: draft and regular. If you are prepping for a new release, or you are migrating a codebase, opening a draft PR is a great way for publicly showing the current development status of that given milestone. When a branch is feature complete, and has been adequately tested then you should open up a regular PR.

# 3. Writing a title & description

Please make the title clean and concise, preferably explaining what the objective of the pieces of committed code are doing. Some things to know:

- A good example message: `Add support for USD to ETH conversion`

Our repositories typically have a template for pull requests, therefore writing the body of a pull request should be straightforward. If the repositories doesn't, a clear concise explanation of the changes made should be included in bullet points, and any relevant issues should be closed following the format `Closes #45`.

# 4. Submit for review

- Add the relevant team members (or the team) for review.
- Add the according labels based on the project
- Ensure you adhere to the repositories PR template.
    - If a template is not provided contact you Tech Lead or Project Manager for insights.
- Always ensure you are descriptive, when explaining the nature of your pull request.