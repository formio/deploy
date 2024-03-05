#!/bin/bash

# Prompt for Kubernetes namespace
echo -n "Enter Kubernetes namespace: "
read k8s_namespace

# Prompt for application name
echo -n "Enter app name: "
read app_name
echo ""

# Display rollout history for the application
kubectl -n $k8s_namespace rollout history deploy $app_name
echo ""

# Prompt for revision number
echo -n "Enter revision number: "
read revision_number

# Ask if user wants to describe the revision
read -p "Would you like to describe the revision? (y/n) " answer
case $answer in
    [yY]* )
        echo "Describing revision $revision_number"
        kubectl -n $k8s_namespace rollout history deploy $app_name --revision=$revision_number
        ;;
    [nN]* )
        echo "Continuing..."
        ;;
    * )
        echo "Invalid input"
        ;;
esac

# Confirm before continuing with the selected revision
read -p "Are you sure you'd like to continue with revision $revision_number? (y/n) " confirm
case $confirm in
    [yY]* )
        echo "Rolling back to revision #$revision_number"
        kubectl -n $k8s_namespace rollout undo deploy $app_name --to-revision=$revision_number
        ;;
    [nN]* )
        echo "Cancelling..."
        ;;
    * )
        echo "Invalid input"
        ;;
esac
