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
#-----------------------------
echo "Starting demux of $POD5_DIR"

echo "KIT_NAME: $KIT_NAME"
echo "SAMPLE_SHEET: $SAMPLE_SHEET"
# head $SAMPLE_SHEET

DEMUX_STAMP="${STAMP_DIR}/demux_stamp.txt"
#-----------------------------

if [ -f "${DEMUX_STAMP}" ]; then 
  echo "${DEMUX_STAMP} exists. Skipping 'dorado demux'"
else
  echo "Running 'dorado demux'"
  # running 'dorado basecaller' in DORADO_MODEL_DIR 
  # so that it finds the models downloaded there
  cd $DORADO_MODEL_DIR


  apptainer exec \
      --nv \
    ${DORADO_SIF_PATH} \
    bash -c \
    "dorado basecaller \
      ${DEMUX_MODEL_STRING} \
      ${POD5_DIR} \
      --device ${DORADO_DEVICE} \
      --kit-name ${KIT_NAME} \
      --sample-sheet ${SAMPLE_SHEET} | \
      dorado demux \
        --threads ${SLURM_JOB_CPUS_PER_NODE} \
        --no-classify \
        --output-dir ${SIMPLEX_DEMUX_DIR}"
  
  mv ${SIMPLEX_DEMUX_DIR}/unclassified.bam ${SIMPLEX_DEMUX_DIR}/unclassified_dot_bam
  date > $DEMUX_STAMP

fi


# Need to submit subsequent jobs here, because the number of per-channel pod5 
# files isn't known until after "pod5 running" subset. We need to know the 
# number of files to submit as an sbatch array
# sbatch --job-name=main_2 --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" 
${SCRIPT_PATH}/main_part2__sbatch.sh