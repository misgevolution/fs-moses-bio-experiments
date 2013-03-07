#!/bin/bash
#
# Evaluate the precision and recall of all experiments for train and
# test

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

bnd=$(basename $dataset)

set -x

samples="train"
if [[ $Kfd > 1 ]]; then
    samples+=" test"
fi

for smp in $samples; do
    for p in $(uniq_prefixes "$exp_dir/res" "_cnd_*_${smp}.csv"); do
        fold=$(grep '[0-9]*to[0-9]*' <(echo "$p") -o)
        actual_file=$exp_dir/data/$bnd.${smp}_$fold
        for sc in precision recall; do
            for cnd in $(seq 0 $(($candidates - 1))); do
                prediction_file=${p}_cnd_${cnd}_${smp}.csv
                $sc $actual_file $prediction_file out
            done | stats > ${p}_${smp}_${sc}.stats
        done
    done
done
