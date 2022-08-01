Note: This is an MVP of a collection that provides access to datasets supporting Alliage Academy ](link.com) tutorials and documentation. Currently only datasets setup is provided.

# Alliage Datasets

The playbooks provide access to the following tasks through the command-line:

1. Download and verify chekcsums of three datasets:
   - NYC Taxi in parquet format.
   - IMDB in tsv format
   - Moby in txt format.
2. Create folder for selected user on hdfs
3. Moves each dataset to hdfs

## How to use

The commands can be made available in three ways:

- With TDP-getting-started: Connecting this collection that TDP that then can be called through an `ansible command`
- With TDP-LIB: Use through tdp-lib. For more info move to the `tdp-lib` branch
- With BASH-SCRIPT: Use through an edge-node. For more info move to the `bash-script` branch
  
**Use with TDP Getting Started:**

The easiest way to interact with Alliage Collection Academy is by adding the collection on your tdp-getting-started repository.

- Use the `main` branch of current repository
- Install (tdp-getting-started)[https://github.com/TOSIT-IO/tdp-getting-started]

After installing you can simply run the following command to download a dataset:

```bash
ansible-playbook deploy-datasets.yml -e "dataset=imdb dataset_user=tdp_user"
```

To declare what username will deploy the command add `dataset_user=*yourusername*"`. The default will be `tdp_user`.

## TODO:

- Complete README
- Verify already installed datasets [x]
- Option to delete specific datasets [x]
- Option to download dataset in selected time-frame [ ]
- Spark job to change parquet to csv if needed [ ]
- Alliage Academy tutorials playbooks & test clusters [ ]

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

