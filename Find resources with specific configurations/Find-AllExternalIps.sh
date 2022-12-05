#### Description #################################################################################
#
# Indexes all external IP addresses used by Compute Engine instances in a GCP environment.
#
####

#! /usr/bin/env/bash

all_external_ips=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      enabled=$(gcloud services list --project "$project" 2>/dev/null | grep "Compute Engine API")

      if [[ -z "$enabled" ]]; 
      then
            echo "Compute Engine API disabled"
      else
            external_ips=$(gcloud compute instances list --project "$project" --format="value(networkInterfaces[].accessConfigs[0].natIP)" --filter="networkInterfaces[].accessConfigs[0].type:ONE_TO_ONE_NAT AND status:running")
            all_external_ips+=(${external_ips[@]})

            echo ${external_ips[@]}
      fi

      echo ""
done

echo "-----"
echo "Compute instances are exposed on the following external IP addresses:"
printf '%s\n' "${all_external_ips[@]}" | uniq | sort
