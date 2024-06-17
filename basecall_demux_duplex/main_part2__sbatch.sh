#!/usr/bin/env bash

set -u 
shopt -s nullglob

#-----------------------------
BAM_DIR_ARRAY=(${SIMPLEX_DEMUX_DIR}/*.bam)
# BAM_DIR_ARRAY=( "${RAW_BAM_DIR_ARRAY[@]/${UNCLASSIFIED_BAM}}" ) # skip unclassified.bam

FILE_COUNT=${#BAM_DIR_ARRAY[@]}
FILE_COUNT=$(( $FILE_COUNT - 1 ))

#-----------------------------

# 2. Duplex basecalling https://github.com/nanoporetech/dorado?tab=readme-ov-file#duplex
JOBID_20=$(sbatch --parsable --array=0-$FILE_COUNT --job-name=dorado_duplex --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/dorado_duplex__sbatch_job.sh)

# 3. Demux. Need to demux before mapping because demux trims reads!
# JOBID_30=$(sbatch --parsable --dependency=afterok:${JOBID_20} --job-name=demux --output="$LOG_DIR/%x-%A-%a.log" --error="$LOG_DIR/%x-%A-%a.log" ${SCRIPT_PATH}/demux__sbatch_job.sh)
# sjobexitmod -l 8207864 | grep FAILED

# 3.5 figure out about duplex reads
#       A. are duplex reads demuxed?
#       B. are simplex reads that contribute to duplex reads demuxed
#       C. Do I need to filter either duplex reads or simplex reads that contribute to duplex reads before mapping?
# https://github.com/nanoporetech/dorado/issues/327
# https://github.com/nanoporetech/dorado/issues/189
#
# samtools view -b -h -d dx:1 all_reads.bam > duplex.bam
# samtools view -b -h -d dx:0 all_reads.bam > simplex.bam
#
# The below code should output a bam file containing only duplex (dx:1) and unpaired simplex (dx:0) reads with the donor simplex (dx:-1) reads removed

# printf "1\n0\n" > tag.txt
# samtools view -b -h -D dx:tags.txt all_reads.bam > duplex_Simplex.bam

# 4. Map reads
# Run Mapping and Sorting
# sbatch --dependency=afterok:$JOBID_1 --array=0-$FILE_COUNT --job-name=map --output="$BAM_DIR/%x-%A-%a.log" --error="$BAM_DIR/%x-%A-%a.log" sbatch_map_job.sh
#-----


#-----------------------------

