# Alliage Academy

This repository provides assets used by [Alliage Academy](https://alliage.io/en/academy/).

It is intended to become an Ansible collection to interface more easily with the future releases of [TDP](https://github.com/TOSIT-IO/TDP).

## Assets

Only one asset is provided for now. More will be added as the platform develops.

### Datasets

These scripts make it easy to incorporate the datasets used in the tutorials of Alliage Academy into HDFS.

#### Covered datasets

- [`IMdB`]()
- [`NYC Green Taxi Trip`]()

#### Usage

From an edge node of a TDP getting started cluster:

  - without parameters:
    ```
    curl -s https://url/to/the/script | bash
    ```
  - with parameters:
    ```
    curl -s https://url/to/the/script | bash -s --option1 arg1
    ```

Use `--help` flag on both scripts for more information on how to use them.
