#!/usr/bin/env bash

# #SBATCH --partition=chsi
# #SBATCH -A chsi

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G

set -Eeuo pipefail # https://stackoverflow.com/a/821419

echo "Starting demux of $UBAM_DIR"

DEMUX_STAMP="${STAMP_DIR}/demux_stamp.txt"

#------------------------------------
# Merge uBAMS
#------------------------------------
# Merge per POD5 uBAMs, because 'dorado demux' won't merge them 
# it doesn't like that the @PG lines aren't identical because they contain the name of the input pod5s

if [ -f "${MERGED_UBAM}" ]; then 
  echo "${MERGED_UBAM} exists. Skipping 'samtools merge'"
else
  echo "Running 'samtools merge' on per-channel uBAMs"
apptainer exec \
	${DORADO_SIF_PATH} \
	samtools merge \
		-o $MERGED_UBAM \
		--threads $SLURM_JOB_CPUS_PER_NODE \
		$UBAM_DIR/*.ubam
fi
# Unless the -c or -p flags are specified then when merging @RG and @PG records into the output header then any IDs found to be duplicates of existing IDs in the output header will have a suffix appended to them to differentiate them from similar header records from other files and the read records will be updated to reflect this.
# -c
# When several input files contain @RG headers with the same ID, emit only one of them (namely, the header line from the first file we find that ID in) to the merged output file. Combining these similar headers is usually the right thing to do when the files being merged originated from the same file.

# Without -c, all @RG headers appear in the output file, with random suffixes added to their IDs where necessary to differentiate them.

# -p
# Similarly, for each @PG ID in the set of files to merge, use the @PG line of the first file we find that ID in rather than adding a suffix to differentiate similar IDs.

#------------------------------------
# Demux uBAMS
#------------------------------------
if [ -f "${DEMUX_STAMP}" ]; then
	echo "${DEMUX_STAMP} exists. Skipping 'dorado demux'"

elif [ ! -f "${MERGED_UBAM}" ]; then 
	echo "${MERGED_UBAM} does not exists. Giving up."
	exit 1
else
	echo "Running 'dorado demux'"
	apptainer exec \
		${DORADO_SIF_PATH} \
		dorado demux \
			--verbose \
			--threads $SLURM_JOB_CPUS_PER_NODE \
			--no-classify \
			--sample-sheet ${SAMPLE_SHEET} \
			--output-dir $DEMUX_DIR \
			$MERGED_UBAM

	# rename unclassified.bam so that it gets ignored in subsequent steps
	# that look for *.bam files we are really interested in wasting time 
	# mapping those reads since they failed demux
	mv ${DEMUX_DIR}/*unclassified.bam ${DEMUX_UNCLASS_DIR}

	date > $DEMUX_STAMP
fi

# Need to submit subsequent jobs here so we can use the number of demuxed BAM
# files for setting up the sbatch array.
# Could parse this from the sample sheet in the future!

echo "Running main_part2__sbatch.sh"
${SCRIPT_PATH}/main_part2__sbatch.sh
