#### Description #################################################################################
#
# Indexes all instances of Cloud Memorystore for Redis in an environment which do not enforce the
# use of SSL/TLS.
#
####

#! /usr/bin/env/bash

all_redis_instances_n=0
redis_instances_without_tls=()

for project in $(gcloud projects list --format="get(projectId)"); do
      echo "[*] scraping project: $project"

      enabled=$(gcloud services list --project "$project" 2>/dev/null | grep -iF "Redis API")

      if [[ "$enabled" ]]
      then
            for region in $(gcloud redis regions list --project "$project" --format json | jq -r '.[] | .locationId')
            do
                  redis_instances=$(gcloud redis instances list --project "$project" --region "$region" --format json 2>/dev/null | jq -r '.[] | .name')

                  for redis_instance in ${redis_instances[@]}
                  do
                        ((all_redis_instances_n++))
                        tls_encryption=$(gcloud redis instances describe "$redis_instance" --project "$project" --region "$region" --format json | jq -r '.transitEncryptionMode')

                        if [[ "$tls_encryption" == "DISABLED" ]]
                        then
                              echo "[!] TLS encryption disabled: $redis_instance"
                              redis_instances_without_tls+=($(echo "$redis_instance" | sed "s|projects/||"))
                        fi
                  done
            done
      else
            echo "Cloud Memorystore for Redis API disabled"
      fi

      echo ""
done

echo "-----"
echo "The following ${#redis_instances_without_tls[@]} Redis instances out of the $all_redis_instances_n in the environment do not enforce the use of TLS:"
printf '%s\n' "${redis_instances_without_tls[@]}" | sort
