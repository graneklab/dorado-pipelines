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
export SCRIPT_PATH

CONFIG_FILE="${1:-${SCRIPT_PATH}/tsample_demo_config.sh}"
echo "USING CONFIG: $CONFIG_FILE"
source "$CONFIG_FILE"

#-----------------------------
# Auto-configured variables

export RESULTS_DIR="${OUTDIR}/results"
export DORADO_MODEL_DIR="${OUTDIR}/dorado_models"

export LOG_DIR="${RESULTS_DIR}/log_dir"
export STAMP_DIR="${RESULTS_DIR}/stamp_dir"
# export SPLIT_POD5_DIR="${RESULTS_DIR}/split_pod5s"
export UBAM_DIR="${RESULTS_DIR}/ubams"
export DEMUX_DIR="${RESULTS_DIR}/demuxed_ubams"
# export SIMPLEX_DEMUX_DIR="${RESULTS_DIR}/simplex_demuxed_ubams"

# export READID_DIR="${RESULTS_DIR}/read_ids"
# export DUPLEX_UBAM_DIR="${RESULTS_DIR}/duplex_ubams"

# export MERGED_UBAM="${UBAM_DIR}/merged_ubam.bam"
#-----------
mkdir -p $RESULTS_DIR $LOG_DIR $STAMP_DIR $UBAM_DIR $DEMUX_DIR
echo "RESULTS_DIR: $RESULTS_DIR"
echo "LOG_DIR: $LOG_DIR"
#-----------------------------
# Apptainer Bind
SAMPLE_SHEET_DIR=$(dirname $SAMPLE_SHEET)
export APPTAINER_BINDPATH="${OUTDIR},${POD5_DIR},${SAMPLE_SHEET_DIR}"
#-----------------------------
POD_DIR_ARRAY=(${POD5_DIR}/*.pod5)

FILE_COUNT=${#POD_DIR_ARRAY[@]}
FILE_COUNT=$(( $FILE_COUNT - 1 ))
#-----------------------------


# 0. Download Dorado Models
srun --job-name=demux --partition=chsi -A chsi --ntasks=1 --cpus-per-task=40 --mem=300G ${SCRIPT_PATH}/demux__sbatch_job.sh
# srun --job-name=demux --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/demux__sbatch_job.sh)
