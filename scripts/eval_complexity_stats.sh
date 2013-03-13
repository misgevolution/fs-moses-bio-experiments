#!/bin/bash
#
# Evaluate the precision and recall of all experiments for train and
# test

set -u                          # forbid using non defined variables
# set -x                          # debug trace

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

for m in $exp_dir/res/*.moses; do
    ofile_base=$(chg_ext $(basename $m) complexity)
    grep complexity: $m | cut -d" " -f 2 | stats > $exp_dir/anal/$ofile_base
done
