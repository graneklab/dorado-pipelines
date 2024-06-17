#!/usr/bin/env bash

echo "By default will use config_sbatch.sh in the same directory as this script"
echo "An alternate config file can be supplied as a command line option"

set -u 
shopt -s nullglob

# https://stackoverflow.com/a/75973157
{
  declare SCRIPT_INVOKED_NAME="${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"
  declare SCRIPT_NAME="${SCRIPT_INVOKED_NAME##*/}"
  declare SCRIPT_INVOKED_PATH="$( dirname "${SCRIPT_INVOKED_NAME}" )"
  declare SCRIPT_PATH="$( cd "${SCRIPT_INVOKED_PATH}"; pwd )"
  declare SCRIPT_RUN_DATE="$( date )"
}

CONFIG_FILE="${1:-${SCRIPT_PATH}/config_sbatch.sh}"
echo "USING CONFIG: $CONFIG_FILE"
source "$CONFIG_FILE"


echo $DORADO_SIF_PATH
echo $POD5_SIF_PATH

mkdir -p $RESULTS_DIR $LOG_DIR

echo "RESULTS_DIR: $RESULTS_DIR"
echo "LOG_DIR: $LOG_DIR"

# Testing load
JOBID_5=$(sbatch --parsable --job-name=sbatch_test_load --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/sbatch_test_load_job.sh)
