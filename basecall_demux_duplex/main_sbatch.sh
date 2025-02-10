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

CONFIG_FILE="${1:-${SCRIPT_PATH}/config_sbatch.sh}"
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

# export MERGED_UBAM="${UBAM_DIR}/merged_ubam.bam"
#-----------
mkdir -p $RESULTS_DIR $LOG_DIR $STAMP_DIR $SIMPLEX_DEMUX_DIR $DUPLEX_UBAM_DIR $READID_DIR
echo "RESULTS_DIR: $RESULTS_DIR"
echo "LOG_DIR: $LOG_DIR"
#-----------------------------
# Apptainer Bind
SAMPLE_SHEET_DIR=$(dirname $SAMPLE_SHEET)
export APPTAINER_BINDPATH="${OUTDIR},${POD5_DIR},${SAMPLE_SHEET_DIR}"
#-----------------------------
# Log the config file used in this run!
cp $CONFIG_FILE ${RESULTS_DIR}
#-----------------------------
# 0. Download Dorado Models
JOBID_05=$(sbatch --parsable --job-name=download_models --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/download_models__sbatch_job.sh)

# https://github.com/nanoporetech/dorado/issues/600#issuecomment-1915188395

# 1. Subset POD5s by channel https://github.com/nanoporetech/dorado?tab=readme-ov-file#improving-the-speed-of-duplex-basecalling
JOBID_10=$(sbatch --parsable --dependency=afterok:${JOBID_05} --job-name=basecall_demux --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/basecall_demux__sbatch_job.sh)
# JOBID_10=$(sbatch --parsable --job-name=pod5_split --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/pod5_split__sbatch_job.sh)
