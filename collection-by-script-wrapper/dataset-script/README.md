Note: This is an MVP of a collection that provides access to datasets supporting Alliage Academy ](link.com) tutorials and documentation. Currently only datasets setup is provided.

# Alliage Datasets

The script provide access to the following tasks in a single command:

1. Download and verify chekcsums of three posible datasets:
   - NYC Taxi in parquet format.
   - IMDB in tsv format
   - Moby in txt format.
1.. Create folder for selected user on hdfs
1.. Moves each dataset to hdfs

It also allows to list the datasets in hdfs and to delete them.

## Install script with curl

From the edge node run the following commands:

```bash
sudo su
cd /home/tdp_user
curl -LJO https://raw.githubusercontent.com/alliage-io/alliage-collection-academy/tdp-datasets-script/datasets.sh
chown tdp_user datasets.sh
```
## Use the script:

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

## TODO:

- Complete README to add alias
- Option to download dataset in selected time-frame [ ]
- Spark job to change parquet to csv if needed [ ]
- Alliage Academy tutorials playbooks & test clusters [ ]
