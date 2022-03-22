# GitHub Slack Notifications Guide

# Overview

There are two methods for receiving various notifications from GitHub via Slack.

- **Scheduled Reminders**: These allow you receive reminders at some interval about pending PRs on specific repos in a Slack channel.
- **Slackbot Notifications**: Enabling these will cause actions on GitHub to trigger notifications on Slack.

# Slackbot Notifications

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

# Scheduled Reminders

Scheduled Reminders can be configured at the org level or the team level. It is recommend that you use the team level, as this allows team maintainers to setup and maintain them.

Instructions for how to configure team level reminders can be found here: 

[Managing scheduled reminders for your team - GitHub Docs](https://docs.github.com/en/organizations/organizing-members-into-teams/managing-scheduled-reminders-for-your-team)