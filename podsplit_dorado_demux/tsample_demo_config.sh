set -u
#-----------------------------
export DORADO_SIF_PATH='oras://gitlab-registry.oit.duke.edu/granek-lab/granek-container-images/dorado-simg:v0_6_1'
export POD5_SIF_PATH='oras://gitlab-registry.oit.duke.edu/granek-lab/granek-container-images/meta-methylome-simage:v002'
#-----------------------------
#-----------------------------
# T sample data
# export OUTDIR="${SCRATCH_DIR}/${USER}/t_samples_test"
# export POD5_DIR="/datacommons/graneklab/projects/bsf_mb_epigenetics/ont_dna_data/Methylation_T_samples_pool/20240412_1530_P2S-01272-A_PAS28139_d8faa887/pod5"
#-----------------------------
# demo data
SCRATCH_DIR="/cwork/${USER}"
export OUTDIR="${SCRATCH_DIR}/t_samples_demo"
export POD5_DIR="${OUTDIR}/raw_data"
#-----------------------------
# dorado duplex will fail if a requested model is not available for your dataset (e.g. 6mA)
# find model names with: 
# srun --mem=20G -c 2 -A chsi -p chsi apptainer exec oras://gitlab-registry.oit.duke.edu/granek-lab/granek-container-images/dorado-simg:v0_6_1 dorado download --list
export DORADO_MODEL_STRING="sup,5mC_5hmC,6mA"
#-----------------------------
export KIT_NAME="SQK-NBD114-96" # for options run see --kit-name in `dorado demux --help`
# srun --mem=5G -c 2 -A chsi -p chsi apptainer exec oras://gitlab-registry.oit.duke.edu/granek-lab/granek-container-images/dorado-simg:v0_6_1 dorado demux --help

#--------------
## Sample Sheet
#--------------
# Sample Sheet Examples and Details
# https://github.com/nanoporetech/dorado/blob/release-v0.6/tests/data/barcode_demux/sample_sheet.csv
# https://github.com/nanoporetech/dorado/blob/master/documentation/SampleSheets.md
# https://community.nanoporetech.com/docs/prepare/library_prep_protocols/experiment-companion-minknow/v/mke_1013_v1_revdc_11apr2016/sample-sheet-upload

export SAMPLE_SHEET="/datacommons/graneklab/projects/bsf_mb_epigenetics/ont_dna_data/Methylation_T_samples_pool/methylation_tsample_sample_sheet.csv"
#-----------------------------

# REF_GENOME="${OUTDIR}/data/wf-basecalling-demo/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta"
# OUT_DIR="${OUTDIR}/output"
#-----------------------------





# export MINKNOW_OUTDIR="/hpc/group/graneklab/projects/premier/2023_10_30/PreMiEr_Isolates_Helena_hospital/PreMiEr_Isolates_Helena_hospital/20231030_1656_MN33275_FAV01083_89688e43"

# export BAM_DIR="${RESULTS_DIR}/bam_dir"
# export MERGED_BAM="${BAM_DIR}/merged_unmap.bam"
# export FILTERED_BAM="${BAM_DIR}/merged_unmap_filtered.bam"

# export DORADO_OUTPUT_BAM=${BAM_DIR}/jb_soil_unmapped.bam
# export FASTQ_DIR="${RESULTS_DIR}/fastq_dir"

# export OUTPUT_FASTQ=${FASTQ_DIR}/$(basename "$DORADO_OUTPUT_BAM" "_unmapped.bam")".fastq.gz"

# export DATA_DIR="${OUTDIR}/seqdata"
# export DORADO_MODEL_DIR="${OUTDIR}/models"

# export DORADO_CALLING_MODEL="dna_r10.4.1_e8.2_400bps_sup@v4.2.0"
# export DORADO_MOD_MODEL="dna_r10.4.1_e8.2_400bps_sup@v4.2.0" # "dna_r9.4.1_e8_sup@v3.6" # 
#-----------------------------
