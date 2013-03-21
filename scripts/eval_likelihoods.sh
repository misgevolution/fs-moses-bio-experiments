#!/bin/bash
#
# Evaluate the likelihoods of all models obtained during the experiment

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

for fd in $(seq 1 $Kfd); do
    fds=${fd}to${Kfd}
    ifile=$exp_dir/data/$bnd.train_${fds}
    for p in $(uniq_prefixes "$exp_dir/anal/fd_$fds" "_cnd_*.combo"); do
        CMD="eval-candidate"
        CMD+=" -i $ifile"
        CMD+=" -u out"
        CMD+=" -H prerec"
        CMD+=" -p $model_combination_noise"
        CMD+=" --complexity-amplifier $complexity_amplifier"
        CMD+=" -n 1"
        CMD+=" --prerec-min-recall $recall_min"
        if [[ prerec_simple_precision == true ]]; then
            CMD+=" --prerec-simple-precision 1"
        else
            CMD+=" --prerec-simple-precision 0"
        fi
        for cnd in $(seq 0 $((candidates - 1))); do
            cfile="${p}_cnd_${cnd}.combo"
            CMD+=" -C $cfile"
        done
        ofile="${p}.weights"
        CMD+=" -o $ofile"
        echo "$CMD"
    done
done | $PPAR
