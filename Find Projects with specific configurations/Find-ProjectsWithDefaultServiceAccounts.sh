#### Description #################################################################################
#
# Indexes all projects in a GCP environement and verifies whether they contain at least one default service account for Compute or App Engine.
#
####

#! /usr/bin/env/bash

projects_with_default_service_accounts=()
total_number_of_projects=$(gcloud projects list --format="get(projectId)" | wc -l)

for project in $(gcloud projects list --format="get(projectId)"); do
      echo "[*] scraping project '$project'"

      service_accounts_n=$(gcloud iam service-accounts list --project "$project" --filter="disabled: False AND displayName ~ default" --format="value(displayName)" | wc -l)

      if [[ $service_accounts_n > 0 ]];
      then
            service_accounts=$(gcloud iam service-accounts list --project "$project" --filter="disabled: False AND displayName ~ default" --format="value(displayName)")
            echo "$service_accounts"

            projects_with_default_service_accounts+=("$project")
      fi

      echo ""
done

echo "-----"
echo "The following ${#projects_with_default_service_accounts[@]} GCP projects out of the $total_number_of_projects in total in the environment contain at least one default service account:"
printf '%s\n' "${projects_with_default_service_accounts[@]}" | sort
