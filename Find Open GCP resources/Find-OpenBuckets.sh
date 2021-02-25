#### Description #################################################################################
#
# Indexes all the Cloud Storage Buckets in a GCP environement and verifies whether they are accessible to "allUsers" or "allAuthenticatedUsers".
# Note: Buckets that are publicly exposed are easy to identify through the console for a single project.
# 
####

#! /usr/bin/env/bash

for proj in $(gcloud projects list --format="get(projectId)"); do
    echo "[*] scraping project $proj"
    for bucket in $(gsutil ls -p $proj); do
        echo "    $bucket"
        ACL="$(gsutil iam get $bucket)"

        all_users="$(echo $ACL | grep allUsers)"
        all_auth="$(echo $ACL | grep allAuthenticatedUsers)"

        if [ -z "$all_users" ]
        then
              :
        else
              echo "[!] Open to all users: $bucket"
        fi

        if [ -z "$all_auth" ]
        then
              :
        else
              echo "[!] Open to all authenticated users: $bucket"
        fi
    done
done
