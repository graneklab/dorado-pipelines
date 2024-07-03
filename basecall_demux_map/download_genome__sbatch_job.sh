#!/usr/bin/env bash

# #SBATCH --partition=chsi
# #SBATCH -A chsi
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G

# set -Eeuo pipefail # https://stackoverflow.com/a/821419
set -u

echo ${REFERENCE_GENOME_MD5} > ${GENOME_DIR}/genome_md5.txt

cd ${GENOME_DIR}

md5sum -c "${GENOME_DIR}/genome_md5.txt"
MD5_RESULT=$?

if [ "$MD5_RESULT" -eq 0 ]; then
    echo "Reference genome validated"
else
    echo "Need to download reference genome"
    apptainer exec \
		${CURL_SIF} \
		curl \
			--output ${REFERENCE_GENOME} \
			${REFERENCE_GENOME_URL}
	md5sum -c "${GENOME_DIR}/genome_md5.txt"
fi
