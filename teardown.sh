#!/bin/sh

# Exit if any command fails
set -e

# Ask for confirmation
read -p \
"---
WARNING
---
This will delete an entire project,
including a Kubernetes cluster and all websites/webservices therein.
Type 'DELETE' to proceed.
" -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ "DELETE" ]]
then
    echo "Aborting."
    exit
fi

echo "DELETING PROJECT"

# Log in
gcloud auth login cameronhudson8@gmail.com

# Delete the project
gcloud projects delete cameronhudson8-my-kube -q
