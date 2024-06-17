#!/usr/bin/env bash

set -Eeuo pipefail # https://stackoverflow.com/a/821419


# https://slurm.schedmd.com/sbatch.html#SECTION_INPUT-ENVIRONMENT-VARIABLES
# srun --pty -p scavenger-gpu --gpus=RTX2080:1 /bin/bash


# #SBATCH --ntasks=1
# #SBATCH --cpus-per-task=6
# #SBATCH --gres=gpu:1

export SBATCH_GPUS="RTX2080:1"
export SBATCH_ACCOUNT="chsi"
export SBATCH_PARTITION="scavenger-gpu"
export SBATCH_MEM_PER_NODE="0"
export SBATCH_EXCLUSIVE=""

sbatch --parsable --job-name=scav_test scavenger_test_job.sh
