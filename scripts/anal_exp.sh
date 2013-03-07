#!/bin/bash
#
# Analyze a series of experiments on biological data. In terms of
# score and diversity.

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

set -x

# Eval the output of all candidates for train and test
$PROG_DIR/eval_all_moses_output.sh $1

# Eval all outputs and sum them up in stats files
$PROG_DIR/eval_train_test_mean_score.sh $1

# Eval the diversity of the 10 top candidates for each experiment
$PROG_DIR/eval_diversity.sh $1

# Create CSV file with the results of all experiments
$PROG_DIR/gather_scores_diversities.sh $1 > $exp_dir/results.csv

# Summarize the CSV file averaging over folds and random seeds
$PROG_DIR/group_mean_by_settings.sh $1 $exp_dir/results.csv > $exp_dir/avg_results.csv
