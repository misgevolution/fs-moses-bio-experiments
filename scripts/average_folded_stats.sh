#!/bin/bash
#
# Take all folded stats and average them

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

for rand in ${rand_seq[@]}; do
    pref="$exp_dir/anal/r${rand}"
    # scores
    for sc in precision recall; do
        for s in $(uniq_suffixes "${pref}_fd_*_" "train_${sc}.stats"); do
            for fd in $(seq 1 $Kfd); do
                grep_stat mean ${pref}_fd_${fd}to${Kfd}_$s
            done | stats > ${pref}_$s
        done
    done

    # diversity
    for s in $(uniq_suffixes "${pref}_fd_*_" ".diversity"); do
        for fd in $(seq 1 $Kfd); do
            grep_stat mean ${pref}_fd_${fd}to${Kfd}_$s
        done | stats > ${pref}_$s
    done

    # complexity
    for s in $(uniq_suffixes "${pref}_fd_*_" ".complexity"); do
        for fd in $(seq 1 $Kfd); do
            grep_stat mean ${pref}_fd_${fd}to${Kfd}_$s
        done | stats > ${pref}_$s
    done
done

