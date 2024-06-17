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

#-----------------------------
# Auto-configured variables

export RESULTS_DIR="${WORK_DIR}/results"
export LOG_DIR="${RESULTS_DIR}/log_dir"
export STAMP_DIR="${RESULTS_DIR}/stamp_dir"
export SPLIT_POD5_DIR="${RESULTS_DIR}/split_pod5s"
#-----------------------------
# export APPTAINER_BINDPATH="/opt,/data:/mnt"
export APPTAINER_BINDPATH="${WORK_DIR},${POD5_DIR}"
#-----------------------------
mkdir -p $RESULTS_DIR $LOG_DIR $STAMP_DIR

echo "RESULTS_DIR: $RESULTS_DIR"
echo "LOG_DIR: $LOG_DIR"
#-----------------------------

#-----------------------------
POD_DIR_ARRAY=(${SPLIT_POD5_DIR}/channel-*.pod5)

FILE_COUNT=${#POD_DIR_ARRAY[@]}
FILE_COUNT=$(( $FILE_COUNT - 1 ))
#-----------------------------


# Run Dorado
JOBID_1=$(sbatch --parsable --array=0-$FILE_COUNT --job-name=dorado --output="$BAM_DIR/%x-%A-%a.log" --error="$BAM_DIR/%x-%A-%a.log" sbatch_dorado_job.sh)

# Run Mapping and Sorting
sbatch --dependency=afterok:$JOBID_1 --array=0-$FILE_COUNT --job-name=map --output="$BAM_DIR/%x-%A-%a.log" --error="$BAM_DIR/%x-%A-%a.log" sbatch_map_job.sh
#-----

# 3. Demux?
# 4. Map reads
