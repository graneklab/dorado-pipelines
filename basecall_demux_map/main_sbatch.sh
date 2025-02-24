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

export CURL_SIF="docker://curlimages/curl:8.8.0"

export RESULTS_DIR="${OUTDIR}/results"
export DORADO_MODEL_DIR="${OUTDIR}/dorado_models"

export LOG_DIR="${RESULTS_DIR}/log_dir"
export STAMP_DIR="${RESULTS_DIR}/stamp_dir"
# export SPLIT_POD5_DIR="${RESULTS_DIR}/split_pod5s"
export UBAM_DIR="${RESULTS_DIR}/ubams"
export DEMUX_DIR="${RESULTS_DIR}/demuxed_ubams"
export DEMUX_UNCLASS_DIR="${RESULTS_DIR}/demuxed_unclassified"
export MERGED_UBAM="${UBAM_DIR}/merged_ubam.bam"
export MAPPED_BAM_DIR="${RESULTS_DIR}/mapped_bams"
# export SIMPLEX_DEMUX_DIR="${RESULTS_DIR}/simplex_demuxed_ubams"

# export READID_DIR="${RESULTS_DIR}/read_ids"
# export DUPLEX_UBAM_DIR="${RESULTS_DIR}/duplex_ubams"

export GENOME_DIR="${OUTDIR}/genome"
export REFERENCE_GENOME=${GENOME_DIR}/$(basename "$REFERENCE_GENOME_URL")
#-----------
mkdir -p $RESULTS_DIR $LOG_DIR $STAMP_DIR $UBAM_DIR $DEMUX_DIR ${GENOME_DIR} ${MAPPED_BAM_DIR} ${DEMUX_UNCLASS_DIR}
echo "RESULTS_DIR: $RESULTS_DIR"
echo "LOG_DIR: $LOG_DIR"
#-----------------------------
# Apptainer Bind
SAMPLE_SHEET_DIR=$(dirname $SAMPLE_SHEET)
export APPTAINER_BINDPATH="${OUTDIR},${POD5_DIR},${SAMPLE_SHEET_DIR}"
echo "APPTAINER_BINDPATH: ${APPTAINER_BINDPATH}"
#-----------------------------
# POD_DIR_ARRAY=(${POD5_DIR}/*.pod5)

# Recursively search $POD5_DIR for pod5 files
# https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash/54561526#54561526
readarray -d '' POD_DIR_ARRAY < <(find ${POD5_DIR} -name \*.pod5 -print0)


FILE_COUNT=${#POD_DIR_ARRAY[@]}
FILE_COUNT=$(( $FILE_COUNT - 1 ))
#-----------------------------
# Log the config file used in this run!
cp $CONFIG_FILE ${RESULTS_DIR}
#-----------------------------
# 0. Download Dorado Models
JOBID_05=$(sbatch --parsable --job-name=download_models --partition=${CPUJOB_PARTITION} --account=${CPU_ACCOUNT} --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/download_models__sbatch_job.sh)

JOBID_06=$(sbatch --parsable --job-name=download_genome --partition=${CPUJOB_PARTITION} --account=${CPU_ACCOUNT} --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/download_genome__sbatch_job.sh)
export JOBID_06 # mapping depends on the genome

# https://github.com/nanoporetech/dorado/issues/600#issuecomment-1915188395

# 1. Basecall individual POD5 files
JOBID_20=$(sbatch --parsable --dependency=afterok:${JOBID_05} --array=0-$FILE_COUNT --job-name=dorado_basecall --partition=${GPUJOB_PARTITION} --account=${GPU_ACCOUNT} --gpus=${GPUJOB_GPUS} --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/basecall__sbatch_job.sh)

# 3. Demux. Need to demux before mapping because demux trims reads!
JOBID_30=$(sbatch --parsable --dependency=afterok:${JOBID_20} --job-name=demux --partition=${CPUJOB_PARTITION} --account=${CPU_ACCOUNT} --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/demux__sbatch_job.sh)
