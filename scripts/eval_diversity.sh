#!/bin/bash
#
# Evaluate diversity between all models of a given experiment

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

for p in $(uniq_prefixes "$exp_dir/anal/" "_cnd_*_train.csv"); do
    CMD="eval-diversity -u out --display-stats 1 --diversity-dst tanimoto"
    for cnd in $(seq 0 $(($candidates - 1))); do
        CMD+=" -i ${p}_cnd_${cnd}_train.csv"
    done
    CMD+=" -o $p.diversity"
    echo "$CMD"
    # $CMD
done | $PPAR
