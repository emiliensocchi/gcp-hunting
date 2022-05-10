#### Description #################################################################################
#
# Indexes all Cloud SQL instances in an environment, filters out those that are access directly 
# (outside Cloud SQL Auth Proxy) and verifies whether they enforce SSL/TLS connections.
#
####

#! /usr/bin/env/bash

instances_with_authorized_networks_n=0                            # instances most likely accessed outside of Cloud SQL Auth Proxy
instances_with_authorized_networks_without_ssl_enforcement_n=0
instances_with_authorized_networks_without_ssl_enforcement=()

for project in $(gcloud projects list --format="get(projectId)"); do
      echo "[*] scraping project: $project"

      sql_instances=$(gcloud sql instances list --project "$project" --format="json" | jq -r '.[] | .name')

      for sql_instance in ${sql_instances[@]}
      do
            authorized_networks=$(gcloud sql instances describe "$sql_instance" --project "$project" --format="json" | jq -r '.settings | .ipConfiguration' | grep -Fi authorizednetworks)

            if [[ -z "$authorized_networks" ]]
            then
                  echo "${project}/${sql_instance} -> No authorized network (most likely consumed via Cloud SQL Proxy)"
            else
                  ((instances_with_authorized_networks_n++))
                  require_ssl=$(gcloud sql instances describe "$sql_instance" --project "$project" --format="json" | jq -r '.settings | .ipConfiguration | .requireSsl')

                  if [[ "$require_ssl" == 'null' || "$require_ssl" == 'false' ]]
                  then
                        ((instances_with_authorized_networks_without_ssl_enforcement_n++))
                        instances_with_authorized_networks_without_ssl_enforcement+=(${project}/${sql_instance})
                        echo "[!] SSL/TLS encryption not enforced:${project}/${sql_instance}"
                  fi
            fi
      done

      echo ""
done

echo "-----"
echo "The following $instances_with_authorized_networks_without_ssl_enforcement_n Cloud SQL instances out of the $instances_with_authorized_networks_n with authorized networks in the environment do not enforce SSL/TLS connections:"
printf '%s\n' "${instances_with_authorized_networks_without_ssl_enforcement[@]}" | sort
