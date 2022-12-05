#### Description #################################################################################
#
# Indexes all Google Kubernetes Engine (GKE) clusters in an environment and retrieves the IP 
# address of their control planes.
#
####

#! /usr/bin/env/bash

all_gke_control_plane_ips=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      ips=$(gcloud container clusters list --project "$project" --format json | jq -r '.[] | .endpoint')

      if [[ "$ips" ]]
      then
            all_gke_control_plane_ips+=(${ips[@]})
      fi

      echo ""
done

echo "-----"
echo "GKE clusters in the environment are publicly exposed on the following IP addresses:"
printf '%s\n' "${all_gke_control_plane_ips[@]}" | sort
