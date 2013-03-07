#!/bin/bash
#
# Split dataset into 2*K dataset with train and test, following the
# naming scheme:
#
# DATA_SET.train_i DATA_SET.test_i
#
# for i = 1, ..., K

if [[ $# != 2 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 DATASET K"
    echo
    echo "Generate 2*K datasets for k-fold cross-validation."
    echo "The files follow the naming scheme"
    echo
    echo "DATA_SET.train_itoK DATA_SET.test_itoK"
    echo
    echo "for i=1,...,K"
    echo
    echo "If K == 1 then only 1 train file is generated, no test"
    exit 1
fi

DATASET="$1"
K="$2"

if [[ $K > 1 ]]; then
    for i in $(seq 1 $K); do
        train="$DATASET.train_${i}to$K"
        test="$DATASET.test_${i}to$K"
        header=1
        offset=$((i + header))
        test_cmd="${header}p;${offset}~${K}p"     # keep header and test
        train_cmd="${offset}~${K}!p"         # discard test (keep header and train)
        sed -n "$test_cmd" "$DATASET" > "$test"
        sed -n "$train_cmd" "$DATASET" > "$train"
    done
else
    cp "$DATASET" "$DATASET.train_1to1"
fi
