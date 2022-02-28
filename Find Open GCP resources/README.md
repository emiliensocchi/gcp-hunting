# Find Open GCP resources

Collection of scripts to find publicly exposed GCP resources. 


## Prerequisite

- gcloud ([instructions](https://cloud.google.com/sdk/docs/install#deb))
- A user account with read access to all the projects in the environment


## Usage

### Connect to the control plane

```shell
gcloud auth login
```

### Find open GCP resources

```shell
bash Find-OpenBuckets.sh
```
