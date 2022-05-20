#### Description #################################################################################
#
# Finds the Compute instance associated with the passed IP address.
#
####

#! /usr/bin/env/bash

if [[ $# -ne 1 ]]
then
      echo "[!] Missing argument"
      echo "Usage: $(basename $0) <ip-address>"
      exit 0
fi

passed_ip="$1"
found_compute_instance=''

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      enabled=$(gcloud services list --project "$project" 2>/dev/null | grep "Compute Engine API")

      if [[ -z "$enabled" ]]; 
      then
            echo "Compute Engine API disabled"
      else
            found_ip=$(gcloud compute instances list --project "$project" --format="value(name, networkInterfaces[].accessConfigs[0].natIP)" --filter="networkInterfaces[].accessConfigs[0].type:ONE_TO_ONE_NAT AND status:running" | grep "$passed_ip")

            if [[ "$found_ip" ]]
            then
                  found_compute_instance="${project}/$(echo $found_ip | awk '{print $1}')"
                  echo "[!] Found Compute instance"
                  echo "-----"
                  echo "The '$passed_ip' IP address is associated with the following Compute instance:"
                  echo "$found_compute_instance"
                  exit 0
            fi
      fi

      echo ""
done
