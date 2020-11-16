#!/bin/bash

# Globals
WIKI_COMMIT_MESSAGE=$(git log -1 --pretty=%B)

git remote add wiki https://$GITHUB_API_KEY@github.com/ChainSafe/engineering-wiki.wiki.git > /dev/null 2>&1
git fetch wiki
git checkout wiki/master
git merge origin/main --no-edit
git push wiki HEAD:master > /dev/null 2>&1

exit 0