# Alliage Datasets

The playbooks provide access to the following tasks in a single command:

1. Download and verify chekcsums of three posible datasets:
   - NYC Taxi in parquet format.
   - IMDB in tsv format
   - Moby in txt format.
2. Create folder for selected user on hdfs
3. Moves each dataset to hdfs

It also allows to list the datasets in hdfs and to delete them.

## Install collection with tdp-getting-started

To use this collection with tdp-lib-getting-started:

1. Clone [TDP Getting Started](https://github.com/TOSIT-IO/tdp-getting-started/)
1. Replace the tdp-getting-started script in `scripts/setup.sh` with the `setup.sh` file in this repository.
1. Install tdp-getting-started through tdp-lib with the same steps performed in their readme.
2. Once deployed the commands to install the dataset script is available:

```bash
tdp deploy --target datasets_install # installs all dataset script
```
## Use catasets command on the Edge-node

SSH to the edge-node and log as a valid user (for instance, tdp_user):

```bash
vagrant ssh edge-01.tdp
sudo su tdp_user
```

Now you can use the following commands:

```bash
 tdp-gs datasets                      Display datasets downloaded
 tdp-gs download all                  Download all datasets (or the ones missing) and move to hdfs.
 tdp-gs download <name>               Download and move to hdfs selected file (if not missing)
 tdp-gs delete <name>                 Deletes the dataset
```

## TODO:

- Complete README
- Input different users through the j2 template [ ]
- Option to download dataset in selected time-frame [ ]
- Spark job to change parquet to csv if needed [ ]
- Alliage Academy tutorials playbooks & test clusters [ ]

## Architecture:

- **Roles:**
  - **`roles/defaults/main.yml`**: variable declaration. 
    - Lookup function to retrieve vars based on input
    - Three datasets, their url's, extension and additional information necesary to downloading the correct datasets and timeframes.
  - **`roles/tasks/install.yml`**: 
    - Moves script and installs `tdp-gs` alias.
  - **`roles/templates/datasets.sh.j2`**: 
    - Datasets.sh scrip, templates the dataset user.
- **Playbooks:**
  - **`playbooks/dataset_install.yml`**: Calls selected installation roles
  - **`playbooks/meta/datasets.yml`**: Calls install and configuration roles, and future rules that need to be deployed under a single command.
