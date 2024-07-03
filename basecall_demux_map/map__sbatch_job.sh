#!/usr/bin/env bash

# #SBATCH --partition=chsi
# #SBATCH -A chsi

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=150G


set -Eeuo pipefail # https://stackoverflow.com/a/821419

#-------------------------------
UNMAPPED_BAM_ARRAY=(${DEMUX_DIR}/*.bam)
UNMAPPED_BAM=${UNMAPPED_BAM_ARRAY[$SLURM_ARRAY_TASK_ID]}
BAM_BASE=$(basename ${UNMAPPED_BAM} )
# UNSORTED_BAM="${UNSORTED_BAM_DIR}/${BAM_BASE}"
FINAL_BAM="${MAPPED_BAM_DIR}/${BAM_BASE}"

ALIGN_STAMP="${STAMP_DIR}/aligner_${BAM_BASE}.txt"

#-------------------------------
echo ${UNMAPPED_BAM}
echo ${FINAL_BAM}
#-------------------------------
#-----------------------------
if [ -f "${ALIGN_STAMP}" ]; then 
  echo "${ALIGN_STAMP} exists. Skipping dorado aligner"
else
  echo "Running dorado aligner on ${UNMAPPED_BAM}"


apptainer exec \
  ${DORADO_SIF_PATH} \
  bash -c \
  "dorado aligner \
    -t $SLURM_JOB_CPUS_PER_NODE \
    $REFERENCE_GENOME \
    $UNMAPPED_BAM \
    | \
    samtools sort \
      --write-index \
      -o $FINAL_BAM \
      --threads $SLURM_JOB_CPUS_PER_NODE \
      -m 5G"

  date > ${ALIGN_STAMP}

fi

