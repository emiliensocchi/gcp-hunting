#### Description #################################################################################
#
# Indexes the user-managed keys used by every services account in an envionment.
# 
# Useful to identify service accounts with a large number of keys, and therefore with a higher 
# risk of being compromised due the private part of the key pairs being managed by individuals.
#
# Note: the console only shows keys that are user managed and not Google-managed keys
#
####

#! /usr/bin/env/bash

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      service_accounts=$(gcloud iam service-accounts list --project "$project" --format="json" | jq -r '.[] | .email')

      for service_account in ${service_accounts[@]}
      do
            echo "Service account: $service_account"
            gcloud iam service-accounts keys list --iam-account "$service_account" --managed-by user --project "$project" 
            echo ""
      done

      echo ""
done
