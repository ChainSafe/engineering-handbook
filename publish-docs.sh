#!/bin/bash

# Globals
GIT_REPOSITORY_URL="https://${GH_PERSONAL_ACCESS_TOKEN}@github.com/ChainSafe/engineering-wiki.wiki.git"
WIKI_COMMIT_MESSAGE=$(git log -1 --pretty=%B)

# Setup the wiki repo
(
    git remote add wiki $GIT_REPOSITORY_URL
    git config user.name "ChainSafe Wiki Bot"
    git config user.email "chainsafe-bot@users.noreply.github.com"
    
    git checkout 
    git add .
    git commit -m "$WIKI_COMMIT_MESSAGE"
    git push --set-upstream $GIT_REPOSITORY_URL master
)

exit 0