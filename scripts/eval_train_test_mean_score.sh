#!/bin/bash
#
# Evaluate the precision and recall of all experiments for train and
# test

set -u                       # error on unassigned variables
# set -x                          # debug

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
lds=$exp_dir/data/$bnd  # local copy of dataset

samples="train"
if [[ $Kfd > 1 ]]; then
    samples+=" test"
fi

# stats for train
for p in $(uniq_prefixes "$exp_dir/anal/" "_cnd_*_train.csv"); do
    fold=$(grep '[0-9]*to[0-9]*' <(echo "$p") -o)
    actual_file=$lds.train_$fold
    for sc in precision recall; do
        for cnd in $(seq 0 $(($candidates - 1))); do
            prediction_file=${p}_cnd_${cnd}_train.csv
            $sc $actual_file $prediction_file out
        done | stats > ${p}_train_${sc}.stats
    done
done

# stats for unfolded test
for p in $(uniq_prefixes "$exp_dir/anal/" "_cnd_*_test.csv"); do
    fold=$(grep '[0-9]*to[0-9]*' <(echo "$p") -o)
    actual_file=$lds
    if [[ $fold != "" ]]; then
        continue     # skip folded test file
    fi
    for sc in precision recall; do
        for cnd in $(seq 0 $(($candidates - 1))); do
            prediction_file=${p}_cnd_${cnd}_test.csv
            $sc $actual_file $prediction_file out
        done | stats > ${p}_test_${sc}.stats
    done
done

# stats for unfolded combined test
for p in $(uniq_prefixes "$exp_dir/anal/" "_combined.csv"); do
    fold=$(grep '[0-9]*to[0-9]*' <(echo "$p") -o)
    actual_file=$lds
    if [[ $fold != "" ]]; then # not folded test file
        continue
    fi
    for sc in precision recall; do
        prediction_file=${p}_combined.csv
        $sc $actual_file $prediction_file out > ${p}_combined.${sc}
    done
done
