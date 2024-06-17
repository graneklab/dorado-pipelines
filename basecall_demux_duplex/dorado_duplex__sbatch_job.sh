#!/usr/bin/env bash

#SBATCH --partition=chsi-gpu
#SBATCH -A chsi

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=0
#SBATCH --gres=gpu:1

set -u

#-------------------------------
if [ -v SLURM_GPUS_ON_NODE ] && (( $SLURM_GPUS_ON_NODE >= 1 )); then
  export DORADO_DEVICE="cuda:all" ;
else 
  export DORADO_DEVICE="cpu" ;
fi
echo $DORADO_DEVICE
echo ${DORADO_SIF_PATH}
#-----------------------------
RAW_BAM_DIR_ARRAY=(${SIMPLEX_DEMUX_DIR}/*.bam)
UNCLASSIFIED_BAM=${SIMPLEX_DEMUX_DIR}/${UNCLASSIFIED_BAM_BASE}
BAM_DIR_ARRAY=( "${RAW_BAM_DIR_ARRAY[@]/${UNCLASSIFIED_BAM}}" ) # skip unclassified.bam

#-----------------------------
BAM_FILE=${BAM_DIR_ARRAY[$SLURM_ARRAY_TASK_ID]}
BAM_BASE=$(basename "$BAM_FILE" ".bam")
DORADO_OUTPUT_BAM="${DUPLEX_UBAM_DIR}/${BAM_BASE}.bam"
READ_ID_FILE="${READID_DIR}/${BAM_BASE}_readids.txt"
#-----------------------------
DORADO_DUPLEX_STAMP="${STAMP_DIR}/dorado_duplex_${BAM_BASE}.txt"
#-----------------------------
if [ -f "${READ_ID_FILE}" ]; then 
  echo "${READ_ID_FILE} exists. Skipping read_id extraction"
else
  echo "Running samtools view on ${BAM_FILE}"
  apptainer exec \
    ${DORADO_SIF_PATH} \
    bash -c \
      "samtools view ${BAM_FILE} | cut -f 1" \
    > ${READ_ID_FILE}
  
fi

#-----------------------------

if [ -f "${DORADO_DUPLEX_STAMP}" ]; then 
  echo "${DORADO_DUPLEX_STAMP} exists. Skipping dorado duplex"
else
  echo "Running dorado duplex on ${BAM_FILE}"

  # running 'dorado duplex' in DORADO_MODEL_DIR 
  # so that it finds the models downloaded there
  cd $DORADO_MODEL_DIR

  # dorado duplex <model> <pod5> --read-ids reads.txt
  apptainer exec \
    --nv \
    ${DORADO_SIF_PATH} \
    dorado duplex \
      ${DORADO_MODEL_STRING} \
      ${POD5_DIR} \
      --device $DORADO_DEVICE \
      --threads $SLURM_JOB_CPUS_PER_NODE \
      --read-ids ${READ_ID_FILE} \
    > ${DORADO_OUTPUT_BAM}
  
  date > $DORADO_DUPLEX_STAMP

fi
