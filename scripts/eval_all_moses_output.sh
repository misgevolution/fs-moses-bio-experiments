#!/bin/bash
#
# Parse and evaluate all models obtained during th experiment

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

# Parse all moses output files
find $exp_dir/res -name "*.moses" -exec $PROG_DIR/parse_moses_output.sh {} \;

# Evaluate each combo program
bnd=$(basename $dataset)

samples="train"
if [[ $Kfd > 1 ]]; then
    samples+=" test"
fi

for fd in $(seq 1 $Kfd); do
    for cfile in $exp_dir/res/*${fd}to${Kfd}*.combo; do
        for smp in $samples; do
            ifile="$exp_dir/data/${bnd}.${smp}_${fd}to${Kfd}"
            ofile=$(chg_ext $(ibe "$cfile" _$smp) csv)
            CMD="eval-table -i $ifile -C $cfile -o $ofile --labels 1 -u out"
            echo "$CMD"
            $CMD
        done
    done
done