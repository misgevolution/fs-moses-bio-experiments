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

r1_fd_10to10_fsm_conf_-0.1_focus_active_seed_init_smp_pbty_0.1_fsm_algo_hc_fsm_scorer_mi.moses

for m in $exp_dir/res/*.moses; do
    ofile=$(chg_ext $m complexity)
    grep complexity: $m | cut -d" " -f 2 | stats > $ofile
done
