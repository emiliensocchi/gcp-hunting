# Find Open GCP resources

Collection of scripts to find publicly exposed GCP resources. 


## Prerequisite

- gcloud ([instructions](https://cloud.google.com/sdk/docs/install#deb))
- A user account with read access to all the projects in the environement


## Usage

### Connect to the control plane

`$ gcloud auth login`

### Find open GCP resources

`$ bash Find-OpenBuckets.sh`
