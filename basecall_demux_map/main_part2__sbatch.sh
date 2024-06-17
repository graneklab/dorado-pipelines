#!/usr/bin/env bash


set -Eeuo pipefail # https://stackoverflow.com/a/821419

shopt -s nullglob

BAM_DIR_ARRAY=(${DEMUX_DIR}/*.bam)

FILE_COUNT=${#BAM_DIR_ARRAY[@]}
FILE_COUNT=$(( $FILE_COUNT - 1 ))
#-----------------------------

# 4. Map reads: Run Mapping and Sorting
JOBID_40=$(sbatch --parsable --dependency=afterok:${JOBID_06} --array=0-$FILE_COUNT --job-name=align --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/map__sbatch_job.sh)

