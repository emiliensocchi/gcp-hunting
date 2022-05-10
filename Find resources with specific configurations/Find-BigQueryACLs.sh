#### Description #################################################################################
#
# Indexes all BigQuery instances in an environement and prints out their Data Set and Table/View ACL,
# to check whether further restrictions than the ones applied at a Project level are defined.
#
# Note: under testing - not sure if useful
#
####

#! /usr/bin/env/bash

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
                  views=$(bq ls --project_id "$project" --format=json "$dataset" | jq -r '.[] | .id')
            
                  for view in ${views[@]}
                  do
                        # ACAB is the default value for empty Cloud IAM permissions, meaning that permissons are most likey set on a the resource's parent (i.e. the GCP Project)
                        bq get-iam-policy "$view"
                  done
            done   
      fi

      echo ""
done
