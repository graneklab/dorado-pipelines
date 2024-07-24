#!/usr/bin/env bash


set -Eeuo pipefail # https://stackoverflow.com/a/821419

shopt -s nullglob

BAM_DIR_ARRAY=(${DEMUX_DIR}/*.bam)

FILE_COUNT=${#BAM_DIR_ARRAY[@]}
FILE_COUNT=$(( $FILE_COUNT - 1 ))
#-----------------------------

echo "Queueing map__sbatch_job.sh, depends on ${JOBID_06}"
# 4. Map reads: Run Mapping and Sorting
# JOBID_40=$(sbatch --parsable --dependency=afterok:${JOBID_06} --array=0-$FILE_COUNT --job-name=align --partition=${CPUJOB_PARTITION} --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/map__sbatch_job.sh)

# removing dependency on download_genome because SLURM doesn't like it anymore (it used to work)
JOBID_40=$(sbatch --parsable --array=0-$FILE_COUNT --job-name=align --partition=${CPUJOB_PARTITION} --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/map__sbatch_job.sh)
