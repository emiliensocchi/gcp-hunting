#### Description #################################################################################
#
# Indexes all external IP addresses belonging to GKE instances in a GCP environement. 
#
####

#! /usr/bin/env/bash

all_gke_external_ips=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      enabled=$(gcloud services list --project "$project" 2>/dev/null | grep "Compute Engine API")

      if [[ -z "$enabled" ]]; 
      then
            echo "Compute Engine API disabled"
      else
            gke_external_ips=$(gcloud compute instances list --project "$project" --format="value(networkInterfaces[].accessConfigs[0].natIP)" --filter="networkInterfaces[].accessConfigs[0].type:ONE_TO_ONE_NAT AND status:running AND name~gke.*")
            all_gke_external_ips+=(${gke_external_ips[@]})

            echo ${gke_external_ips[@]}
      fi

      echo ""
done

echo "-----"
echo "Compute instances used as GKE nodes are exposed on the following external IP addresses:"
printf '%s\n' "${all_gke_external_ips[@]}" | uniq | sort
