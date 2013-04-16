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

AN_DIR="$exp_dir/anal"

prefix="$AN_DIR/fd_*_"

# scores
for sc in precision recall; do
    for s in $(uniq_suffixes "$prefix" "train_${sc}.stats"); do
        for fd in $(seq 1 $Kfd); do
            grep_stat mean "$AN_DIR/fd_${fd}to${Kfd}_$s"
        done | stats > "$AN_DIR/$s"
    done
done

# diversity
for s in $(uniq_suffixes "$prefix" ".diversity"); do
    for fd in $(seq 1 $Kfd); do
        grep_stat mean "$AN_DIR/fd_${fd}to${Kfd}_$s"
    done | stats > "$AN_DIR/$s"
done

# complexity
for s in $(uniq_suffixes "$prefix" ".complexity"); do
    for fd in $(seq 1 $Kfd); do
        grep_stat mean "$AN_DIR/fd_${fd}to${Kfd}_$s"
    done | stats > "$AN_DIR/$s"
done
