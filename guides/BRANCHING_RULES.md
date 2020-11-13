[Back to Table of Contents](../README.md#Table-of-Contents)

At ChainSafe we no longer use branch `Master`

### Default Branch

The default branch should be `main`. For the majority of the time, pull requests will be merged into the `main` branch.

### Personal Branches

Should follow the format `<name>/<feature>` for example: `greg/create-readme`. You can use your username, or some other unique identifier, but please keep it consistent. The reason for this, is that git stores branches in this format, when it views a `/` its assumed to be a directory. Thus when you look at a git project `.git/refs/heads` you will see everyone has their own folder with their branches!

### Release Branches

When making a release, a corresponding tag should be created using git ex: `git tag v0.23.1-rc`. In the case where a previous build needs to be back ported, a release branch should be created with the prefix `release` and the corresponding version number eg: `release/v0.23.1-rc`.
