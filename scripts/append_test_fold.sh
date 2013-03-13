#!/bin/bash
#
# Take all the evaluated test files from a given setting and candidate
# and append then in the same csv file, as to simply and accuratly
# compute test precision

set -u                       # error on unassigned variables
set -x                          # debug

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

for rand in ${rand_seq[@]}; do
    for s in $(uniq_suffixes "$exp_dir/res/r${rand}_fd_*_" "_test.csv"); do
        CMD="appendCSVFiles"
        for fd in $(seq 1 $Kfd); do
            CMD+=" $fd"
        done
        ofile="$dir_exp/res/r${rand}_$s"
        $CMD > $ofile
    done
done
