#!/usr/bin/env bash

# #SBATCH --partition=chsi-gpu
# #SBATCH -A chsi

# #SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=20G
# #SBATCH --gres=gpu:1

set -Eeuo pipefail # https://stackoverflow.com/a/821419


#-------------------------------
if [ -v SLURM_GPUS_ON_NODE ] && (( $SLURM_GPUS_ON_NODE >= 1 )); then
  export DORADO_DEVICE="cuda:all" ;
else 
  export DORADO_DEVICE="cpu" ;
fi
echo $DORADO_DEVICE
echo ${DORADO_SIF_PATH}
#-----------------------------
# POD_DIR_ARRAY=(${POD5_DIR}/*.pod5)

# Recursively search $POD5_DIR for pod5 files
# https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash/54561526#54561526
readarray -d '' POD_DIR_ARRAY < <(find ${POD5_DIR} -name \*.pod5 -print0)
POD5_FILE=${POD_DIR_ARRAY[$SLURM_ARRAY_TASK_ID]}
POD5_BASE=$(basename "$POD5_FILE" ".pod5")
DORADO_OUTPUT_BAM="${UBAM_DIR}/${POD5_BASE}.ubam"
BASECALL_STAMP="${STAMP_DIR}/dorado_duplex_${POD5_BASE}.txt"
#-----------------------------
echo "Starting basecalling of $POD5_FILE"
echo "KIT_NAME: $KIT_NAME"
echo "SAMPLE_SHEET: $SAMPLE_SHEET"
#-----------------------------
if [ -f "${BASECALL_STAMP}" ]; then 
  echo "${BASECALL_STAMP} exists. Skipping dorado basecaller"
else
  echo "Running dorado basecaller on ${POD5_FILE}"
  # running 'dorado basecaller' in DORADO_MODEL_DIR 
  # so that it finds the models downloaded there
  cd $DORADO_MODEL_DIR

  apptainer exec \
      --nv \
    ${DORADO_SIF_PATH} \
    dorado basecaller \
      ${DORADO_MODEL_STRING} \
      ${POD5_FILE} \
      --device ${DORADO_DEVICE} \
      --kit-name ${KIT_NAME} \
      --sample-sheet ${SAMPLE_SHEET} > \
      ${DORADO_OUTPUT_BAM}
  
  BASECALL_EXIT=$?

  if [ "$BASECALL_EXIT" -eq 0 ]; then
    echo "dorado basecaller successful: ${POD5_BASE}"
    date > ${BASECALL_STAMP}
  else
    echo "dorado basecaller FAILED: ${POD5_BASE}"
  fi

fi
