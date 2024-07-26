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

CONFIG_FILE="${1:-${SCRIPT_PATH}/tsample_demo_config.sh}"
echo "USING CONFIG: $CONFIG_FILE"
source "$CONFIG_FILE"

#-----------------------------
# Auto-configured variables

export UNCLASSIFIED_BAM_BASE="unclassified.bam"
export RESULTS_DIR="${OUTDIR}/results"
export DORADO_MODEL_DIR="${OUTDIR}/dorado_models"

export LOG_DIR="${RESULTS_DIR}/log_dir"
export STAMP_DIR="${RESULTS_DIR}/stamp_dir"
export SPLIT_POD5_DIR="${RESULTS_DIR}/split_pod5s"
# export UBAM_DIR="${RESULTS_DIR}/ubams"
export SIMPLEX_DEMUX_DIR="${RESULTS_DIR}/simplex_demuxed_ubams"
export READID_DIR="${RESULTS_DIR}/read_ids"
export DUPLEX_UBAM_DIR="${RESULTS_DIR}/duplex_ubams"
#-----------------------------
# export APPTAINER_BINDPATH="/opt,/data:/mnt"
export APPTAINER_BINDPATH="${OUTDIR},${POD5_DIR}"
#-----------------------------
mkdir -p $RESULTS_DIR $LOG_DIR $STAMP_DIR

echo "RESULTS_DIR: $RESULTS_DIR"
echo "LOG_DIR: $LOG_DIR"
#-----------------------------

#-----------------------------
#-----------------------------
#-----------------------------
#-----------------------------
RAW_BAM_DIR_ARRAY=(${SIMPLEX_DEMUX_DIR}/*.bam)
echo "FILE_COUNT1: ${#RAW_BAM_DIR_ARRAY[@]}"

UNCLASSIFIED_BAM=${SIMPLEX_DEMUX_DIR}/${UNCLASSIFIED_BAM_BASE}
BAM_DIR_ARRAY=( "${RAW_BAM_DIR_ARRAY[@]/${UNCLASSIFIED_BAM}}" ) # skip unclassified.bam

FILE_COUNT=${#BAM_DIR_ARRAY[@]}
FILE_COUNT=$(( $FILE_COUNT - 1 ))

echo "FILE_COUNT2: ${#BAM_DIR_ARRAY[@]}"

echo "FILE_COUNT3: $FILE_COUNT"
echo "BAM_DIR_ARRAY: ${BAM_DIR_ARRAY[@]}"

#-----------------------------
