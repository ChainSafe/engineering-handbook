
[Back to Table of Contents](../README.md#Table-of-Contents)

This is a step-by-step release guide for ChainSafe projects

# 1. Preconditions

### 1.1 Define clear milestone for the release

Every release should be accompanied by a related milestone or epic. A release should never be made without an actual goal, this includes a bug fix, since a bug fix should have a corresponding issue or set of issues.

### 1.2 Collect issues, and pull requests related to the release

Ensure that all the issues, and pull requests are properly organized and cataloged during the  development process. This means that issues should be properly connected to closed pull requests (via zenhub), and pull requests are being closed through Github's automatic issue closing mechanism (eg: git committed contains `Closes #45`).

### 1.3 Identify clear code freeze for given release

Leading up to the release, QA & release branches should be frozen ([https://www.mergefreeze.com/](https://www.mergefreeze.com/) may be a useful tool) until the release has been completed. This is to ensure that there are no bugs accidentally merged into the code base.

# 2. Identify The Release Type

There are three types that a release may fall under:

**Alpha:** These are the first to come out and are therefore the least stable. Most reported errors are resolved but there are most likely still outstanding known issues, which might include security issues.

**Beta:** Beta releases are usually only created once:

- All critical data loss and security bugs are resolved
- The core functionalities are frozen enough so that contributors and users can upgrade.
- Most of the problems with the upgrade path are fixed and it's possible to successfully upgrade a copy of the Drupal.org database to the new Drupal version.

**Release Candidate:** Release candidates are usually only created once no more critical bugs have been reported in a given beta release. These are considered nearly stable code, and no more features can be added.

**Full Release:** After a successful release candidate, a full release can be cut, this would be a production ready, bug free release for public use. 

Tags should resemble the following formats: `v0.1.1-alpha`, `v0.1.1-beta`, `v0.1.1-rc1`, `v0.1.1-rc2`, `v0.1.1`,etc...

# 3. QA the branch

Create a QA branch, and perform the necessary QA checks (outlined per project), if the requirements are met, make an announcement in the necessary channel, and perform any required code freezes.

**Note:** If it is an alpha, or beta release there may be known bugs, in which case you may not need to be as thorough with the QA process.

# 4. Cut The Release

Once you are release ready, cut the appropriate release branch (per the branching guidelines), and tag the related commit using `git tag <release>` (eg: `git tag v0.1.1-RC2`). Push the tag to the remote rep `git push <repo-name> <tag-name>`. On Github create a release and assign it the appropriate tag that was generate previously. The title of the release should begin with the version number, and if you choose so, a snappy title afterwards.

# 5. Generate The Changelog

Generate a changelog explaining the changes made in this release, optionally you can include any PR's or issues that were closed as a part of the release. Append the changelog to the release description that was added in the previous step.

# 6. Generate The Binaries

If the repository requires any binaries, generate them along with their checksum, and attach them to the release from `step 4`. If there is any publishing needed, such as npm, this it the time to do so.
