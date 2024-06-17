#!/usr/bin/env bash

#SBATCH --partition=chsi
#SBATCH -A chsi

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=5G

set -u

export DORADO_SIF_PATH="oras://gitlab-registry.oit.duke.edu/granek-lab/granek-container-images/dorado-simg:v0_6_1"
export TEMP_MODELS="/cwork/josh/temp_models"
mkdir -p $TEMP_MODELS

apptainer exec \
	--bind /cwork/josh \
	${DORADO_SIF_PATH} \
	dorado download \
	--verbose \
	--directory $TEMP_MODELS \
	--data /cwork/josh/basecall_demo/data/wf-basecalling-demo/input
#-----------------------------------------  
Apptainer> dorado download --model "sup,5mCG_5hmCG" --verbose --recursive --directory /cwork/josh/temp_models --data /cwork/josh/basecall_demo/data/wf-basecalling-demo/input
[2024-04-30 14:16:30.059] [info] Running: "download" "--model" "sup,5mCG_5hmCG" "--verbose" "--recursive" "--directory" "/cwork/josh/temp_models" "--data" "/cwork/josh/basecall_demo/data/wf-basecalling-demo/input"
[2024-04-30 14:16:30.418] [info]  - downloading dna_r10.4.1_e8.2_400bps_sup@v4.1.0 with httplib
[2024-04-30 14:16:33.507] [info]  - downloading dna_r10.4.1_e8.2_400bps_sup@v4.1.0_5mCG_5hmCG@v2 with httplib
[2024-04-30 14:16:34.119] [info]  - downloading dna_r10.4.1_e8.2_4khz_stereo@v1.1 with httplib
[2024-04-30 14:16:34.330] [info]  - downloading dna_r10.4.1_e8.2_4khz_stereo@v1.1 with httplib
#-----------------------------------------  
# [2024-04-28 00:55:06.076] [info] Running: "download" "--help"                                                                      
# Usage: dorado [-h] [--model VAR] [--directory VAR] [--list] [--list-yaml] [--data VAR] [--recursive] [--overwrite]                 
                                                                                                                                   
# Optional arguments:                                                                                                                
#   -h, --help            shows help message and exits                                                                               
#   --model               the model to download [default: "all"]                                                                     
#   --directory           the directory to download the models into [default: "."]                                                   
#   --list                list the available models for download                                                                     
#   --list-yaml           list the available models for download, as yaml, to stdout                                                 
#   --data                path to POD5 data used to automatically select models [default: ""]                                        
#   -r, --recursive       recursively scan through directories to load POD5 files                                                    
#   --overwrite           overwrite existing models if they already exist                                                            
#   -v, --verbose                                                                        

# [2024-04-29 09:41:14.122] [info] > modification models

# [2024-04-29 09:41:14.122] [info]  - dna_r10.4.1_e8.2_400bps_sup@v4.3.0_5mC_5hmC@v1
# [2024-04-29 09:41:14.122] [info]  - dna_r10.4.1_e8.2_400bps_sup@v4.3.0_6mA@v1
# [2024-04-29 09:41:14.122] [info]  - dna_r10.4.1_e8.2_400bps_sup@v4.3.0_6mA@v2
# [2024-04-29 09:41:14.122] [info]  - dna_r10.4.1_e8.2_400bps_sup@v4.3.0_5mCG_5hmCG@v1
# [2024-04-29 09:41:14.122] [info] > stereo models
# [2024-04-29 09:41:14.122] [info]  - dna_r10.4.1_e8.2_4khz_stereo@v1.1
# [2024-04-29 09:41:14.123] [info]  - dna_r10.4.1_e8.2_4khz_stereo@v1.1
# [2024-04-29 09:41:14.123] [info]  - dna_r10.4.1_e8.2_5khz_stereo@v1.1
# [2024-04-29 09:41:14.123] [info]  - dna_r10.4.1_e8.2_5khz_stereo@v1.2
# [2024-04-29 09:41:14.123] [info] > simplex models
# [2024-04-29 09:41:14.123] [info]  - dna_r10.4.1_e8.2_400bps_sup@v4.3.0
