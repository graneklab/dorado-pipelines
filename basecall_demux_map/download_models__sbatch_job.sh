#!/usr/bin/env bash

# #SBATCH --partition=chsi
# #SBATCH -A chsi

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=20G
# Requesting more memory than seems necessary because this step seems to hang
# when downloading container image (if it isn't already cached). Guessing it is
# a memory issue.
#SBATCH --time=6:00:00

set -Eeuo pipefail # https://stackoverflow.com/a/821419

mkdir -p $DORADO_MODEL_DIR

# Apptainer> dorado download --model "sup,5mCG_5hmCG" --verbose --recursive --directory /cwork/josh/temp_models --data /cwork/josh/basecall_demo/data/wf-basecalling-demo/input
apptainer exec \
	${DORADO_SIF_PATH} \
	dorado --version 2> \
	${RESULTS_DIR}/dorado_version.txt

apptainer exec \
	${DORADO_SIF_PATH} \
	dorado download \
		--verbose \
		--model ${DORADO_MODEL_STRING} \
		--directory $DORADO_MODEL_DIR \
		--recursive \
		--data ${POD5_DIR}
