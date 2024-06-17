#!/usr/bin/env bash

echo "By default will use config_sbatch.sh in the same directory as this script"
echo "An alternate config file can be supplied as a command line option"

set -u 
shopt -s nullglob

# https://stackoverflow.com/a/75973157
{
  declare SCRIPT_INVOKED_NAME="${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"
  declare SCRIPT_NAME="${SCRIPT_INVOKED_NAME##*/}"
  declare SCRIPT_INVOKED_PATH="$( dirname "${SCRIPT_INVOKED_NAME}" )"
  declare SCRIPT_PATH="$( cd "${SCRIPT_INVOKED_PATH}"; pwd )"
  declare SCRIPT_RUN_DATE="$( date )"
}
export SCRIPT_PATH

CONFIG_FILE="${1:-${SCRIPT_PATH}/config_sbatch.sh}"
echo "USING CONFIG: $CONFIG_FILE"
source "$CONFIG_FILE"

echo $DORADO_MODCALL_MODELS


# # Hack to generate bash array from comma-separated string
# IFS=','; DORADO_MODEL_ARRAY=($DORADO_MODCALL_MODELS); unset IFS

# echo $DORADO_MODEL_ARRAY

# ## Loop over array
# for CUR_MODEL in "${DORADO_MODEL_ARRAY[@]}"
# do
#    echo "CUR_MODEL is: $CUR_MODEL"
# done





