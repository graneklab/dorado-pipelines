#!/usr/bin/env bash

#SBATCH --partition=chsi
#SBATCH -A chsi

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

set -u

echo "SLURM_JOB_NAME: $SLURM_JOB_NAME"

echo $DORADO_SIF_PATH
echo $POD5_SIF_PATH
