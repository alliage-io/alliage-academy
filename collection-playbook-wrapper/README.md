Note: This is an MVP of a collection that provides access to datasets supporting Alliage Academy ](link.com) tutorials and documentation. Currently only datasets setup is provided.

# Alliage Datasets

The playbooks provide access to the following tasks in a single command:

1. Download and verify chekcsums of three posible datasets:
   - NYC Taxi in parquet format.
   - IMDB in tsv format
   - Moby in txt format.
2. Create folder for selected user on hdfs
3. Moves each dataset to hdfs

## How to use

The commands can be deployed in three ways:

- With TDP-DATASETS-SCRIPT: Use through an edge-node. This is the current branch.
- With TDP-getting-started: Use this with a single ansible command. For more info move the main branch.
- With TDP-LIB: Use through tdp-lib. For more info go to the `tdp-lib` branch.

### Install script with curl

From the edge node run the following commands:

```bash
sudo su
cd /home/tdp_user
curl -LJO https://raw.githubusercontent.com/alliage-io/alliage-collection-academy/tdp-datasets-script/datasets.sh
chown tdp_user datasets.sh
```

**Use the script:** 

From the edge node you will be using the script as tdp_user:

```bash
vagrant ssh edge-01.tdp
sudo su tdp_user
```

Now you can use the following commands:

```bash
 ./datasets.sh datasets                      Display datasets downloaded
 ./datasets.sh download all                  Download all datasets (or the ones missing) and move to hdfs.
 ./datasets.sh download <name>               Download and move to hdfs selected file (if not missing)
 ./datasets.sh delete <name>                 Deletes the dataset
```

### Install script with an ansible playbook

- Move `datasets.sh` to `tdp-getting-started/scripts/` of your cloned getting-started repository.
- Move `deploy-datasets.yml` to the root of your getting-started repository
- Run `deploy-datasets,yml` to make the script and allias available in the Edge node:
  
```bash
ansible-playbook deploy-datasets.yml
```

**Use TDP DOWNLOAD SCRIPT:**

To use tdp-gs command you have to first ssh to the edge-01 node and sudo as tdp_user:

```bash
vagrant ssh edge-01.tdp
sudo su tdp_user
```

Now you can use the following commands:

```basg
 tdp-gs datasets                      Display datasets downloaded
 tdp-gs download all                  Download all datasets (or the ones missing) and move to hdfs.
 tdp-gs download <name>               Download and move to hdfs selected file (if not missing)
 tdp-gs delete <name>                 Deletes the dataset
```

## TODO:

- Complete README
- Verify already installed datasets [x]
- Option to delete specific datasets [x]
- Option to download dataset in selected time-frame [ ]
- Spark job to change parquet to csv if needed [ ]
- Alliage Academy tutorials playbooks & test clusters [ ]

## Architecture:

- **`deploy-datasets.yml`**: Moves script and installs `tdp-gs` alias.
- **`datasets.sh`**: tdp-gs command logic
