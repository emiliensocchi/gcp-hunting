#### Description #################################################################################
#
# Indexes the IP addresses and ranges defined as authorizaed networks in all Cloud SQL instances 
# of an environment and determines whether one of them is authorizing the entire Internet.
#
####

#! /usr/bin/env/bash

all_authorized_networks=()
open_sql_instances=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      sql_instances=$(gcloud sql instances list --project "$project" --format="json" | jq -r '.[] | .name')

      for sql_instance in ${sql_instances[@]}
      do
            authorized_networks=$(gcloud sql instances describe "$sql_instance" --project "$project" --format="json" | jq -r '.settings | .ipConfiguration | .authorizedNetworks[]? |.value')
            all_authorized_networks+=(${authorized_networks[@]})

            for authorized_network in ${authorized_networks[@]}
            do
                  if [[ "$authorized_network" == '0.0.0.0/0' ]];
                  then
                        echo "[!] SQL instance opened to the Internet: $project/$sql_instance"
                        open_sql_instances+=("$project/$sql_instance")
                  fi
            done
      done
done

echo "-----"
echo "All authorized networks:"
printf '%s\n' "${all_authorized_networks[@]}" | sort
echo ""
echo "-----"
echo "The following Cloud SQL instances are open to the Internet:"
printf '%s\n' "${open_sql_instances[@]}" | sort


