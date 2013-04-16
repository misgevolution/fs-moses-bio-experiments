#!/bin/bash
#
# For all settings, generate an output resulting of combining
# candidates output by moses for all folds

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

set -u                       # error on unassigned variables
# set -x                          # debug

# Evaluate each combo program
bnd=$(basename $dataset)

for i in $(uniq_infixes "$exp_dir/anal/fd_*_" "_cnd_*_test.csv"); do
    for fd in $(seq 1 $Kfd); do
        fds=${fd}to${Kfd}
        p="$exp_dir/anal/fd_${fds}_$i" # prefix
        # Vote
        CMD="$PROG_DIR/vote.py"
        CMD+=" -t $maj_vote"
        wfile=${p}.weights
        CMD+=" -w $wfile"
        for cnd in $(seq 0 $((candidates - 1))); do
            cndfile=${p}_cnd_${cnd}_test.csv
            CMD+=" -i $cndfile"
        done
        ofile="${p}_combined.csv"
        CMD+=" -o $ofile"
        echo "$CMD"
    done
done | $PPAR
