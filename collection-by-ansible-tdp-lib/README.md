Note: This is an MVP of a collection that provides access to datasets supporting Alliage Academy ](link.com) tutorials and documentation. Currently only datasets setup is provided.

# Alliage Datasets

The playbooks provide access to the following tasks with a single command:

1. Download and verify chekcsums of three posible datasets:
   - NYC Taxi in parquet format.
   - IMDB in tsv format
   - Moby in txt format.
2. Create folder for selected user on hdfs
3. Moves each dataset to hdfs

## How to use

To use this collection with tdp-lib-getting-started:

1. Replace the tdp-getting-started script in `scripts/setup.sh` with the `setup.sh` file in this repository.
1. Install tdp-getting-started through tdp-lib with the same steps performed in their readme.
1. Once deployed the commands to install datasets are available to be used from the host machine through tdp-lib.

To download all available datasetss:

```bash
tdp deploy --target datasets_config # installs all datasets
```

To install only a specific datasets from the ones datasets provided in [Alliage](alliage/content/datasets), use one of the following:

```bash
tdp deploy --target datasets_taxi_config
tdp deploy --target datasets_imdb_config
tdp deploy --target datasets_mobi_config
```

## Architecture:

- **Roles:**
  - **`roles/defaults/main.yml`**: variable declaration. 
    - Lookup function to retrieve vars based on input
    - Three datasets, their url's, extension and additional information necesary to downloading the correct datasets and timeframes.
  - **`roles/tasks/install.yml`**: 
    - Checks user and datasets provided as arguments are correct
    - Check dataset doesn't already exist in HDFS
    - Downloads, verifies checksum and decompresses file (if necesary)
  - **`roles/tasks/config.yml`**: move files to hdfs
    - Setup hdfs folders for selected user
    - Moves files to HDFS
    - Deletes original files
- **Playbooks:**
  - **`playbooks/dataset_install.yml`**: Calls selected installation roles
  - **`playbooks/dataset_config.yml`**: Calls selected configuration roles
  - **`playbooks/meta/datasets.yml`**: Calls install and configuration roles, and future rules that need to be deployed under a single command.

