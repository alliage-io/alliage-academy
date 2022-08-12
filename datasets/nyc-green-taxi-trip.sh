#!/usr/bin/env bash

SCRIPT_VERSION="0.0.0"
DATASET_BASE_URL="https://d37ci6vzurychx.cloudfront.net/trip-data/"
DATASET_MIN_YEAR=2013
DATASET_MAX_YEAR=2021

username="tdp_user"
output_hdfs_dirname="nyc_green_taxi_trip"
from="01-2013"
to="12-2021"

# Options followed by a colon have a required argument
shortopts="u:Vh"
longopts="from:,to:,username:,version,help"

print_usage()
{
  echo "Download IMDb datasets."
  echo
  echo "Usage: imdb.sh [OPTION...]"
  echo
  echo "Options:"
  echo "--from                     month from which to download the dataset"
  echo "                           format: mm-yyyy"
  echo "                           default: 01-2013"
  echo "--to                       month until which to download the dataset"
  echo "                           format: mm-yyyy"
  echo "                           default: 12-2021"
  echo "-u, --username             HDFS user folder to which add the datasets"
  echo "-V, --version              print program version"
  echo "-h, --help                 print this help list"
  echo
}

exit_abnormal() {
  echo "Try 'nyc-green-taxi-trip.sh --help' for more information."
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
  -u|--username) username="$2" ; shift;;
  --from) from="$2" ; shift;;
  --to) to="$2" ; shift;;
  (--) shift; break;;
  (*) break;;
  esac
  shift
done

# Spread dates
IFS=- read -r from_month from_year <<< $from
IFS=- read -r to_month to_year <<< $to

# Check if dates are defined
if [[ -z "$from_month" || -z "$from_year" ]]
then
  echo "Error: Invalid --from type."
  exit_abnormal
fi
if [[ -z "$to_month" || -z "$to_year" ]]
then
  echo "Error: Invalid --to type."
  exit_abnormal
fi

# Check if dates are valid
if [[ "${from_month#0}" -lt 1 || "${from_month#0}" -gt 12 ]]
then
  echo "Error: Invalid --from value."
  echo "Error: Month must be between 01 and 12. Got ${from_month}."
  exit_abnormal
fi
if [[ "${to_month#0}" -lt 1 || "${to_month#0}" -gt 12 ]]
then
  echo "Error: Invalid --to value."
  echo "Error: Month must be between 01 and 12. Got ${to_month}."
  exit_abnormal
fi

# Check if dates are out of range
if [[ $from_year -lt $DATASET_MIN_YEAR || $to_year -gt $DATASET_MAX_YEAR ]]
then
  echo "Error: Invalid year value."
  echo "Error: Date must be between ${DATASET_MIN_YEAR} and ${DATASET_MAX_YEAR}. Got ${from_year}."
  exit_abnormal
fi

# Check if dates are chronological
if [ $from_year -gt $to_year ]
then
  echo "Error: --from date must be before --to date."
  exit_abnormal
fi
if [ $from_year -eq $to_year ]
then
  if [ $from_month -gt $to_month ]
  then
    echo "Error: --from date must be before --to date."
    exit_abnormal
  fi
fi

# Compute covered dates
dates=()

if [ $from_year -eq $to_year ]
then
  for month in $(seq -f "%02g" $from_month $to_month)
  do
    dates+=("${from_year}-${month}")
  done
else
  # First year
  for month in $(seq -f "%02g" $from_month 12)
  do
    dates+=("${from_year}-${month}")
  done
  # Years in-between
  for year in $(seq $((from_year + 1)) $((to_year - 1)))
  do
    for month in {01..12}
    do
      dates+=("${year}-${month}")
    done
  done
  # Last year
  for month in  $(seq -f "%02g" 1 $to_month)
  do
    dates+=("${to_year}-${month}")
  done
fi

# Create HDFS folder if doesn't exist
output_hdfs_path="/user/${username}/${output_hdfs_dirname}"
hdfs dfs -mkdir -p ${output_hdfs_path}

# Download the dataset to HDFS, overwrite if exists
trap 'exit 1' SIGINT
for date in "${dates[@]}"
do
  file_name="green_tripdata_${date}.parquet"
  file_url="${DATASET_BASE_URL}${file_name}"
  echo "Downloading $file_url to ${output_hdfs_path}/${file_name}"
  curl "$file_url" | hdfs dfs -put -f - ${output_hdfs_path}/${file_name}
done

exit 0
