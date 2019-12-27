#!/bin/sh

# Exit if any command fails
set -e

# Log in
gcloud auth login cameronhudson8@gmail.com

# Create the project at set it as active
echo "PROJECT CREATION"
read -p "Enter project ID (must be globally unique): " PROJECT_ID 
read -p "Enter project name: " PROJECT_NAME
gcloud projects create $PROJECT_ID --name $PROJECT_NAME

# Create a cluster
echo "CLUSTER CREATION"
read -p "Enter project ID (must be globally unique): " PROJECT_ID 
gcloud --project=$PROJECT_ID container clusters create

