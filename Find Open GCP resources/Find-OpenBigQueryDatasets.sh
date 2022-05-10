#### Description #################################################################################
#
# Indexes all BigQuery instances in an environement and determines whether they are publicly
# accessible to 'allUsers' or anonymously accessible to 'allAuthenticatedUsers'.
#
####

#! /usr/bin/env/bash

all_publicly_accessible_datasets=()
all_anonymously_accessible_datasets=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      disabled=$(bq ls --project_id "$project" | sed ':b;N;$!bb;s/\n/ /g' | grep -iF 'has not enabled BigQuery')

      if [[ "$disabled" ]]
      then
            echo "BigQuery API disabled"
      else
            datasets=$(bq ls --project_id "$project" --format=json | jq -r '.[] | .id')

            for dataset in ${datasets[@]}
            do 
                  acl=$(bq show --format=prettyjson "$dataset")
                  all_users=$(echo "$acl" | grep allUsers)
                  all_authenticated_users=$(echo "$acl" | grep allAuthenticatedUsers)

                  if [[ "$all_users" ]]
                  then
                        echo "[!] Dataset accessible to all users: $dataset"
                        all_publicly_accessible_datasets+=("$dataset")
                  fi

                  if [[ "$all_authenticated_users" ]]
                  then
                        echo "[!] Dataset accessible to all authenticated users: $dataset"
                        all_anonymously_accessible_datasets+=("$dataset")
                  fi
            done
      fi

      echo ""
done

echo "-----"
echo "The following BigQuery datasets are publicly accessible (by all users):"
printf '%s\n' "${all_publicly_accessible_datasets[@]}" | sort
echo ""
echo "-----"
echo "The following BigQuery datasets are anonymously accessible (by all authenticated users):"
printf '%s\n' "${all_anonymously_accessible_datasets[@]}" | sort
