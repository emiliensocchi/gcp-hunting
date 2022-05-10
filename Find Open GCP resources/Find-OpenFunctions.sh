#### Description #################################################################################
#
# Indexes all Cloud Functions in an environement and determines whether they are publicly
# accessible to 'allUsers' or anonymously accessible to 'allAuthenticatedUsers'.
#
# Note: Functions that are publicly exposed are easy to identify through the console for a single project.
# 
####

#! /usr/bin/env/bash

all_publicly_accessible_functions=()
all_anonymously_accessible_functions=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      enabled=$(gcloud services list --project "$project" | grep -iF "Cloud Functions API")

      if [[ "$enabled" ]]
      then
            for function_region in $(gcloud functions list --quiet --project "$project" --format="value[separator=','](NAME,REGION)")
            do
                  # drop substring from first occurence of "," to end of string.
                  function="${function_region%%,*}"
                  # drop substring from start of string up to last occurence of ","
                  region="${function_region##*,}"
                  function_acl=$(gcloud functions get-iam-policy "$function" --project "$project" --region "$region")

                  is_accessible_to_all_users=$(echo "$function_acl" | grep allUsers)
                  is_accessible_to_all_authenticated_users=$(echo "$function_acl" | grep allAuthenticatedUsers)

                  if [ "$is_accessible_to_all_users" ]
                  then
                        echo "[!] Open to all users: $function"
                        all_publicly_accessible_functions+=("${project}/${function}")
                  fi

                  if [ "$is_accessible_to_all_authenticated_users" ]
                  then
                        echo "[!] Open to all authenticated users: $function"
                        all_anonymously_accessible_functions+=("${project}/${function}")
                  fi
            done
      else
            echo "Cloud Function API disabled"
      fi
      
      echo ""
done
echo "-----"
echo "The following Cloud Functions are publicly accessible (by all users):"
printf '%s\n' "${all_publicly_accessible_functions[@]}" | sort
echo ""
echo "-----"
echo "The following Cloud Functions are anonymously accessible (by all authenticated users):"
printf '%s\n' "${all_anonymously_accessible_functions[@]}" | sort
echo ""
