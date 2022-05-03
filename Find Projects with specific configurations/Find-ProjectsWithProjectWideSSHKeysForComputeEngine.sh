#### Description #################################################################################
#
# Indexes all projects in a GCP environement and verifies whether they contain project-wide SSH keys stored in Compute Engine metadata.
#
####

#! /usr/bin/env/bash

gcloud config set disable_prompts true
projects_with_ssh_keys_in_compute_instance_metadata=()
total_number_of_projects=$(gcloud projects list --format="get(projectId)" | wc -l)


for project in $(gcloud projects list --format="get(projectId)"); do
      echo "[*] scraping project '$project'"

      ssh_keys_n=$(gcloud compute project-info describe --project "$project" --format="json" 2>/dev/null | jq -r '.commonInstanceMetadata | .items[]? | .value' | sed "s/\n/\n\r/" | grep -Ev "(k8s|gke)" | wc -l)
      
      if [[ $ssh_keys_n > 0 ]];
      then
            ssh_keys=$(gcloud compute project-info describe --project "$project" --format="json" 2>/dev/null | jq -r '.commonInstanceMetadata | .items[] | .value' | sed "s/\n/\n\r/" | grep -Ev "(k8s|gke)")
            echo "$ssh_keys"

            projects_with_ssh_keys_in_compute_instance_metadata+=("$project")
      fi

      echo ""
done

echo "-----"
echo "The following ${#projects_with_ssh_keys_in_compute_instance_metadata[@]} GCP projects out of the $total_number_of_projects in total in the environment are managing SSH keys in Compute Engine metadata:"
printf '%s\n' "${projects_with_ssh_keys_in_compute_instance_metadata[@]}" | sort
