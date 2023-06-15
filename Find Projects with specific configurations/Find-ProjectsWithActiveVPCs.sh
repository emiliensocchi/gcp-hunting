#### Description #################################################################################
#
# Indexes all projects in a GCP environement and indexes those that contain a VPC, where at least
# one internal IP address has been assigned to a host.
#
####

#! /usr/bin/env/bash

projects_with_active_vpc=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      enabled=$(gcloud services list --project "$project" 2>/dev/null | grep -iF "Compute Engine API")

      if [[ "$enabled" ]]
      then
            private_ips=$(gcloud compute instances list --project "$project" --format json | jq -r '.[] | .networkInterfaces[]  | .networkIP')

            if [[ "$private_ips" ]]
            then
                  projects_with_active_vpc+=("$project")
                  echo "[!] At least one active VPC"
            fi

      else
            echo "Compute Engine API disabled"
      fi

      echo ""
done

echo "-----"
echo "The following projects contain at least 1 active VPC:"
printf '%s\n' "${projects_with_active_vpc[@]}" | sort
