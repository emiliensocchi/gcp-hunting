#### Description #################################################################################
#
# Indexes all URLs used by App Engine instances in a GCP environement.
#
####

#! /usr/bin/env/bash

all_appengine_urls=()

for project in $(gcloud projects list --format="get(projectId)")
do
      echo "[*] scraping project: $project"

      urls=$(gcloud app services list --project "$project" --format json 2>/dev/null | jq -r '.[] | .versions[] | .version | .versionUrl')
      all_appengine_urls+=(${urls[@]})

      echo ${urls[@]}
      echo ""
done

echo "-----"
echo "App Engine instances are exposed on the following URLs:"
printf '%s\n' "${all_appengine_urls[@]}" | uniq | sort
