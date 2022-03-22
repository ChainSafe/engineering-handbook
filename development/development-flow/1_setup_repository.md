# Setup Github Repository

These are steps to setup a new repo under the ChainSafe Github organization:

<aside>
💡 The org owners are now the Heads of Engineering and they can assist you with any changes you require.
</aside>

# Project Creation

1. Create the project in the ChainSafe organization on Github
    1. If you do not have permission reach out to an org owner (see note above).

# Setup Team Permissions

1. Go to `Settings` → `Manage Access`. 
2.  Add the team and give them **Write** permissions. Avoid inviting individuals, there should be a team on the organization that has everyone working on the project. 
    1. If the team or the admin team doesn't exist, please reach out to an org owner (see note above).

![create_repository_assets/Screenshot_2020-05-07_11-28-00.png](create_repository_assets/Screenshot_2020-05-07_11-28-00.png)

3. Add the admin team (should be "<team-name>-admin") and give them **Admin** permissions

4. Add the **ChainSafe** team with `Read` permissions

- Note: Adding the **ChainSafe** team will give access to the entire org. If the project is sensitive consider not including this team.

# Branch Protection

1. Goto `Settings` → `Branches`
2. If this is a new repo, choose `Add Rule`. In this example you can see a rule already exists for `master` branch, in which case you can select `Edit` to modify it. 

![create_repository_assets/Screenshot_2020-05-12_09-29-27.png](create_repository_assets/Screenshot_2020-05-12_09-29-27.png)

3. These are the base requirements to ensure at least 1 review is required to merge PRs.

![create_repository_assets/Screenshot_2020-05-12_09-30-11.png](create_repository_assets/Screenshot_2020-05-12_09-30-11.png)

Some additional options:

- **Branch name pattern**: some projects use different branch names. `main` is usually the default branch, but rules may also need to applied to a `develop` or `release` branch
- **Required approving reviews**: this can be increased to a number that makes sense for the team size. This is usually 1-3 for most repos.
- **Require status checks to pass before merging**: this should be enabled if CI (eg. Github Actions) is used in the repo.

# Disable Merge Commits & Rebase

1. Goto `Settings`  and scroll down to `Merge button`
    
    ![create_repository_assets/Screenshot_2020-05-12_09-40-08.png](create_repository_assets/Screenshot_2020-05-12_09-40-08.png)
    

2. Disable `Allow merge commits` and `Allow rebase merging`. Since most repos use *squash merging* this prevents anyone from accidentally using one of the other options. If the TL has reason to override this they may certainly do so.

3. Enable `Automatically delete head branches`. This automatically deletes branches once they are merged to help keep the repo organized.

# Basic Readme

Please see other ChainSafe repos for examples of what to include. 

Gossamer: [https://github.com/chainsafe/gossamer](https://github.com/chainsafe/gossamer)

Forest: [https://github.com/chainsafe/forest](https://github.com/chainsafe/forest)

Lodestar: [https://github.com/ChainSafe/lodestar/](https://github.com/ChainSafe/lodestar/)

# License

A license file must be added to the root of the repo in a file named `LICENSE`. Github will automatically pick this up and display it. It's recommended to also ensure the source code of the repo has matching license headers. Please reach out to `David Ansermino` for more details. 

# Continuous Integration

A continuous integration (CI) service must be setup before code is committed. We strongly advise using Github Actions. Even though you may not know what the repository setup structure may resemble, you will know the basic language that will be used, therefore the most simple CI can be setup:

1. Include the linter
2. Include your test runner
3. If possible, add a build step

You should use recommended CI for your programming language which can be found [here](development/tech-stack/readme.md)

# CLA

Please use [https://cla-assistant.io/](https://cla-assistant.io/). This will be automatically enabled for all public repos in the org (status check needs to be required).

# Code Owners

Depending on the project, it might make sense to add a code owners file. Please reference the [github guide](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners) for more information.

# License Checker

[WIP]

# Review

Once everything has been done, and setup, reach out to your Head of Engineering person to double check that everything is setup accordingly.


# Slack notifications
<details>
  <summary>Optional! Click to see.</summary>
  
## Overview

There are two methods for receiving various notifications from GitHub via Slack.

- **Scheduled Reminders**: These allow you receive reminders at some interval about pending PRs on specific repos in a Slack channel.
- **Slackbot Notifications**: Enabling these will cause actions on GitHub to trigger notifications on Slack.

## Slackbot Notifications

The instructions for configuring the GitHub Slackbot can be found here: [https://github.com/integrations/slack#configuration](https://github.com/integrations/slack#configuration)

A common configuration follows these steps:

```yaml
/github subscribe owner/repo
/github subscribe owner/repo reviews comments
```

You can check which features are enabled in a channel with:

```yaml
/github subscribe list features
```
</details>


# Scheduled Reminders

Scheduled Reminders can be configured at the org level or the team level. It is recommend that you use the team level, as this allows team maintainers to setup and maintain them.

Instructions for how to configure team level reminders can be found here: 

[Managing scheduled reminders for your team - GitHub Docs](https://docs.github.com/en/organizations/organizing-members-into-teams/managing-scheduled-reminders-for-your-team)


Good morning y'all!