#!/usr/bin/env bash

SCRIPT_VERSION="0.0.1"
DATASET_BASE_URL="https://d37ci6vzurychx.cloudfront.net/trip-data/"
DATASET_MIN_YEAR=2013
DATASET_MAX_YEAR=2021
TARGET_DIRECTORY="/user/tdp_user/data/nyc_green_taxi_trip"

from="01-2013"
to="12-2021"

shortopts="t:vh"
longopts="from:,to:,target:,version,help"

print_usage()
{
  echo "Download the NYC Green Taxi Trip datasets."
  echo
  echo "The default target directory is \"${TARGET_DIRECTORY}\"."
  echo "File are stored in Parquet format as \"{year}/green_tripdata_{year}-{month}.parquet\""
  echo "There is one file per month."
  echo "The complete dataset is approximately 1.2GB."
  echo
  echo "Usage: nyc-green-taxi-trip.sh [OPTION...]"
  echo
  echo "Options:"
  echo "--from                     month from which to download the dataset"
  echo "                           format: mm-yyyy"
  echo "                           default: 01-2013"
  echo "--to                       month until which to download the dataset"
  echo "                           format: mm-yyyy"
  echo "                           default: 12-2021"
  echo "-t, --target               HDFS target directory"
  echo "-v, --version              print program version"
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
  -h|--help)    print_usage; exit 0;;
  -v|--version) print_version; exit 0;;
  -t|--target)  shift; target="$1";;
  --from)       shift; from="$1";;
  --to)         shift; to="$1";;
  (--)          shift; break;;
  (*) break;;
  esac
  shift
done
target=${target:-${TARGET_DIRECTORY} }

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

# Download the dataset to HDFS, overwrite if exists
trap 'exit 1' SIGINT
for date in "${dates[@]}"
do
  file_name="green_tripdata_${date}.parquet"
  file_url="${DATASET_BASE_URL}${file_name}"
  IFS=- read -r year month <<< $date
  hdfs dfs -mkdir -p ${target}
  echo "Downloading $file_url to ${target}/${file_name}"
  curl "$file_url" | hdfs dfs -put -f - "${target}/${file_name}"
done

exit 0
