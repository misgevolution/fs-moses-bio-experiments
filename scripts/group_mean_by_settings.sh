#!/bin/bash
#
# Take the csv file summing up the experiments and generate one that
# calculate the mean of the results across folds and rands

if [[ $# != 2 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE RES_CSV"
    exit 1
fi

. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

set -x

if [[ $pfs_algo == hc ]]; then
    groups="pre_conf"
else
    groups="pre_nfeats"
fi
if [[ $fsm_algo == hc ]]; then
    groups+=",fsm_conf"
else
    groups+=",fsm_nfeats"
fi
groups+=",focus"

samples="train"
if [[ $Kfd > 1 ]]; then
    samples+=" test"
fi

CMD="mean_group $2 $groups"
for smp in $samples; do
    for sc in precision recall; do
        CMD+=" mean_${sc}_${smp}"
    done
done
CMD+=" diversity"

$CMD
