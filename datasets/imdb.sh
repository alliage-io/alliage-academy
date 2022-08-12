#!/usr/bin/env bash

SCRIPT_VERSION="0.0.0"
DATASETS_FILES=(
  "name.basics.tsv"
  "title.akas.tsv"
  "title.basics.tsv"
  "title.crew.tsv"
  "title.episode.tsv"
  "title.principals.tsv"
  "title.ratings.tsv"
)
DATASETS_BASE_URL="https://datasets.imdbws.com/"

username="tdp_user"
output_hdfs_dirname="imdb"

# Options followed by a colon have a required argument
shortopts="u:hV"
longopts="username:,help,version"

print_usage()
{
  echo "Download IMDb datasets."
  echo
  echo "Usage: imdb.sh [OPTION...]"
  echo
  echo "Options:"
  echo "-u, --username             HDFS user folder to which add the datasets"
  echo "-V, --version              print program version"
  echo "-h, --help                 print this help list"
  echo
}

exit_abnormal() {
  echo "Try 'imdb.sh --help' for more information."
  exit 1
}

print_version()
{
  echo "v$SCRIPT_VERSION"
}

opts=$(getopt -o "$shortopts" -l "$longopts" -- "$@")

# Validate the input
[ $? -eq 0 ] || {
    echo "Incorrect options provided."
    exit_abnormal
}

# Get arguments from options
eval set -- "$opts"
while [ $# -gt 0 ]
do
  case $1 in
  -h|--help) print_usage; exit 0;;
  -V|--version) print_version; exit 0;;
  # An additional shift is required for options with required arguments
  -u|--username) username="$2" ; shift;;
  (--) shift; break;;
  (*) break;;
  esac
  shift
done

# Create HDFS folder if doesn't exist
output_hdfs_path="/user/${username}/${output_hdfs_dirname}"
hdfs dfs -mkdir -p ${output_hdfs_path}

# Download the dataset to HDFS, overwrite if exists
trap 'exit 1' SIGINT
for file in "${DATASETS_FILES[@]}"
do
  file_url="${DATASETS_BASE_URL}${file}.gz"
  echo "Downloading $file_url to ${output_hdfs_path}/${file}"
  curl "$file_url" | gzip -d | hdfs dfs -put - ${output_hdfs_path}/${file}
done

exit 0
