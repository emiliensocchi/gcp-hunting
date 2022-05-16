#### Description #################################################################################
#
# Indexes all Cloud Storage buckets in an environement and determines whether they or one of their
# objects is publicly accessible to 'allUsers' or anonymously accessible to 'allAuthenticatedUsers'.
# 
# Note: Buckets that are publicly exposed are easy to identify through the console for a single project.
# 
####

#! /usr/bin/env/bash

all_publicly_accessible_buckets=()
all_anonymously_accessible_buckets=()
all_publicly_accessible_objects=()
all_anonymously_accessible_objects=()

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

            if [[ -z "$is_accessible_to_all_users" && -z "$is_accessible_to_all_authenticated_users" ]]
            then
                  # Individual objects in the bucket can still be accessible if fine-grained ACLs are in use
                  has_uniform_access=$(gsutil uniformbucketlevelaccess get "$bucket" 2>/dev/null | grep "Enabled: True")

                  if [[ -z "$has_uniform_access" ]]
                  then
                        echo "[*] analyzing objects in bucket: $bucket"

                        objects_max_n=100
                        objects=($(gsutil ls -r "${bucket}**" 2>/dev/null))

                        if [[ ${#objects[@]} -gt objects_max_n ]]
                        then
                              echo "[*] Too many objects in the Bucket, analyzing the first ${objects_max_n}/${#objects[@]} objects"
                              objects=($(echo ${objects[@]:0:${objects_max_n}}))
                        fi

                        # Fine-grained ACLs are in use
                        for object in ${objects[@]}
                        do
                              object_acl=$(gsutil iam get "$object")
                              is_accessible_to_all_users=$(echo "$object_acl" | grep allUsers)
                              is_accessible_to_all_authenticated_users=$(echo "$object_acl" | grep allAuthenticatedUsers)                              

                              if [[ "$is_accessible_to_all_users" ]]
                              then
                                    echo "[!] Object open to all users: $object"
                                    object=$(echo "$object" | sed "s|gs://||")
                                    all_publicly_accessible_objects+=("${project}/${object}")
                              fi

                              if [[ "$is_accessible_to_all_authenticated_users" ]]
                              then
                                    echo "[!] Object open to all authenticated users: $object"
                                    object=$(echo "$object" | sed "s|gs://||")
                                    all_anonymously_accessible_objects+=("${project}/${object}")
                              fi
                        done
                  fi
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
echo ""
echo "-----"
echo "The following Cloud Storage objects are anonymously accessible (by all authenticated users):"
printf '%s\n' "${all_anonymously_accessible_objects[@]}" | sort
echo ""
echo "-----"
echo "The following Cloud Storage objects are anonymously accessible (by all authenticated users):"
printf '%s\n' "${all_publicly_accessible_objects[@]}" | sort
