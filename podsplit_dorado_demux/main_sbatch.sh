#!/usr/bin/env bash

set -Eeuo pipefail # https://stackoverflow.com/a/821419
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


#-----------------------------                                                                                                                                                                                                                                                                                     
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 CONFIG_FILE" >&2
    exit 2
else
    CONFIG_FILE="${1}"
    echo "USING CONFIG: $CONFIG_FILE"
    source "$CONFIG_FILE"
fi
#-----------------------------
# Auto-configured variables

export RESULTS_DIR="${OUTDIR}/results"
export DORADO_MODEL_DIR="${OUTDIR}/dorado_models"

export LOG_DIR="${RESULTS_DIR}/log_dir"
export STAMP_DIR="${RESULTS_DIR}/stamp_dir"
export SPLIT_POD5_DIR="${RESULTS_DIR}/split_pod5s"
export UBAM_DIR="${RESULTS_DIR}/ubams"
export DEMUX_DIR="${RESULTS_DIR}/demuxed_ubams"
export MERGED_UBAM_DIR="${UBAM_DIR}/merged_ubam"
export MERGED_UBAM="${MERGED_UBAM_DIR}/merged_ubam.bam"
# export FASTQ_OUTDIR="${RESULTS_DIR}/fastqs"

export FULL_FASTQS="${RESULTS_DIR}/full_fastqs"
export SIMPLEX_FILTER_BAMS="${RESULTS_DIR}/simplex_filtered_bams"
export SIMPLEX_FILTER_FASTQS="${RESULTS_DIR}/simplex_filtered_fastqs"


#-----------
mkdir -p $RESULTS_DIR $LOG_DIR $STAMP_DIR $UBAM_DIR $DEMUX_DIR $MERGED_UBAM_DIR
echo "RESULTS_DIR: $RESULTS_DIR"
echo "LOG_DIR: $LOG_DIR"
#-----------------------------
# Apptainer Bind
export APPTAINER_BINDPATH="${OUTDIR},${POD5_DIR}"

if [ -v SAMPLE_SHEET ]; then 
  echo "SAMPLE_SHEET IS set"
  SAMPLE_SHEET_DIR=$(dirname $SAMPLE_SHEET)
  export APPTAINER_BINDPATH="${APPTAINER_BINDPATH},${SAMPLE_SHEET_DIR}"
else 
  echo "No SAMPLE_SHEET"
fi
#-----------------------------
# Log the config file used in this run!
cp $CONFIG_FILE ${RESULTS_DIR}
#-----------------------------
# 0. Download Dorado Models
JOBID_05=$(sbatch --parsable --job-name=download_models --partition=${CPUJOB_PARTITION} --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/download_models__sbatch_job.sh) #--account=${CPU_ACCOUNT}

# 1. Subset POD5s by channel https://github.com/nanoporetech/dorado?tab=readme-ov-file#improving-the-speed-of-duplex-basecalling
JOBID_10=$(sbatch --parsable --dependency=afterok:${JOBID_05} --partition=${CPUJOB_PARTITION} --job-name=pod5_split --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/pod5_split__sbatch_job.sh) #--account=${CPU_ACCOUNT}
# JOBID_10=$(sbatch --parsable --job-name=pod5_split --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/pod5_split__sbatch_job.sh)
