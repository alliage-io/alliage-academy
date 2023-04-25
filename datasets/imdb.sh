#!/usr/bin/env bash

SCRIPT_VERSION="0.0.1"
DATASETS_FILES=(
  "name.basics.tsv"
  "title.akas.tsv"
  "title.basics.tsv"
  "title.crew.tsv"
  "title.episode.tsv"
  "title.principals.tsv"
  "title.ratings.tsv"
)
IMDB_SOURCE_BASE_URL=${IMDB_SOURCE_BASE_URL:-"https://datasets.imdbws.com/"}
IMDB_TARGET_DIRECTORY=${IMDB_TARGET_DIRECTORY:-"/user/tdp_user/data/imdb"}

shortopts="t:hv"
longopts="target:,help,version"

print_usage()
{
  echo "Download IMDb datasets."
  echo
  echo "The default target directory is \"${IMDB_TARGET_DIRECTORY}\"."
  echo "It is modifiable with the \"IMDB_TARGET_DIRECTORY\" environmental variable."
  echo "File are stored in TSV format."
  echo "They are not compressed and have the \".tsv\" extension."
  echo "There is one file per table."
  echo "The complete dataset is approximately 5.5GB."
  echo
  echo "Usage: imdb.sh [OPTION...]"
  echo
  echo "Options:"
  echo "-t, --target               HDFS target directory"
  echo "-v, --version              print program version"
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
  -h|--help)    print_usage; exit 0;;
  -v|--version) print_version; exit 0;;
  -t|--target)  shift; target="$1";;
  (--)          shift; break;;
  (*)           break;;
  esac
  shift
done
target=${target:-${IMDB_TARGET_DIRECTORY}}

# Create HDFS folder if doesn't exist
hdfs dfs -mkdir -p ${target}

# Download the dataset to HDFS, overwrite if exists
trap 'exit 1' SIGINT
for file in "${DATASETS_FILES[@]}"
do
  file_url="${IMDB_SOURCE_BASE_URL}${file}.gz"
  echo "Downloading $file_url to ${target}/${file}"
  curl "$file_url" | gzip -d | hdfs dfs -put -f - "${target}/${file}"
done

exit 0
