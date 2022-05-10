#### Description #################################################################################
#
# Indexes all Cloud Storage buckets in an environement and determines whether they are publicly
# accessible to 'allUsers' or anonymously accessible to 'allAuthenticatedUsers'.
# 
# Note 1: Verifies only IAM exposure at the bucket level to save time
# Note 2: Buckets that are publicly exposed are easy to identify through the console for a single project.
# 
####

#! /usr/bin/env/bash

all_publicly_accessible_buckets=()
all_anonymously_accessible_buckets=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      for bucket in $(gsutil ls -p $project)
      do
            echo "[*] analyzing bucket: $bucket"

            bucket_acl=$(gsutil iam get "$bucket")
            is_accessible_to_all_users=$(echo "$bucket_acl" | grep allUsers)
            is_accessible_to_all_authenticated_users=$(echo "$bucket_acl" | grep allAuthenticatedUsers)

            if [[ "$is_accessible_to_all_users" ]]
            then
                  echo "[!] Bucket open to all users: $bucket"
                  bucket=$(echo "$bucket" | sed "s|/||g" | sed "s/gs://")
                  all_publicly_accessible_buckets+=("${project}/${bucket}")
            fi

            if [[ "$is_accessible_to_all_authenticated_users" ]]
            then
                  echo "[!] Bucket open to all authenticated users: $bucket"
                  bucket=$(echo "$bucket" | sed "s|/||g" | sed "s/gs://")
                  all_anonymously_accessible_buckets+=("${project}/${bucket}")
            fi
      done

      echo ""
done

echo "-----"
echo "The following Cloud Storage buckets are publicly accessible (by all users):"
printf '%s\n' "${all_publicly_accessible_buckets[@]}" | sort
echo ""
echo "-----"
echo "The following Cloud Storage buckets are anonymously accessible (by all authenticated users):"
printf '%s\n' "${all_anonymously_accessible_buckets[@]}" | sort
