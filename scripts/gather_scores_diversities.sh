#!/bin/bash
#
# Generate a csv file displaying for each experiment, the average
# train and test score for all candidates and their diversity

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

# debug trace
# set -x
set -u

. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

bnd=$(basename $dataset)

samples="train"
if [[ $Kfd > 1 ]]; then
    samples+=" test"
fi

################
# write header #
################
header="fold,rand"
if [[ $pfs_algo == hc ]]; then
    header+=",pre_conf"
else
    header+=",pre_nfeats"
fi
if [[ $fsm_algo == hc ]]; then
    header+=",fsm_conf"
else
    header+=",fsm_nfeats"
fi
header+=",focus"
for smp in $samples; do
    for sc in precision recall; do
        header+=",mean_${sc}_${smp}"
    done
done
header+=",diversity"
echo "$header"

#################
# write content #
#################
res_dir=$exp_dir/res
data_dir=$exp_dir/data
for fold in $(seq 1 $Kfd); do
    fds=${fold}to${Kfd}
    for rand in ${rand_seq[@]}; do
        rs=r$rand
        ##########
        # No fsm #
        ##########
        for pre_nfeats in ${nfeats_seq[@]}; do
            for pre_conf in ${conf_seq[@]}; do
                fn="$res_dir/${rs}_fd_${fds}_"
                if [[ $pfs_algo == hc ]]; then
                    fn+="conf_$pre_conf"
                else
                    fn+="nfeats_$pre_nfeats"
                fi
                fn+="_no_fsm"
                # settings
                content="$fold,$rand,"
                if [[ $pfs_algo == hc ]]; then
                    content+="$pre_conf"
                else
                    content+="$pre_nfeats"
                fi
                content+=",none,none"
                # score
                for smp in $samples; do
                    for sc in precision recall; do
                        sc_file=${fn}_${smp}_${sc}.stats
                        sc_mean=$(grep_stat mean $sc_file)
                        content+=",$sc_mean"
                    done
                done
                # diversity
                dfile=${fn}.diversity
                dmean=$(grep_stat mean $dfile)
                content+=",$dmean"
                echo "$content"
            done
        done

        #######
        # Fsm #
        #######
        if [[ $no_fsm == true ]]; then
            continue            # skip fsm experiments
        fi
        
        for fsm_nfeats in ${fsm_nfeats_seq[@]}; do
            for fsm_conf in ${fsm_conf_seq[@]}; do
                for focus in ${focus_seq[@]}; do
                    for seed in ${seed_seq[@]}; do
                        for smp_pbty in ${smp_pbty_seq[@]}; do
                            for fsm_scorer in ${fsm_scorer_seq[@]}; do
                                fn="$res_dir/${rs}_fd_${fds}_"
                                if [[ $fsm_algo == hc ]]; then
                                    fn+="fsm_conf_${fsm_conf}"
                                else
                                    fn+="fsm_nfeats_${fsm_nfeats}"
                                fi
                                fn+="_focus_${focus}_seed_${seed}_smp_pbty_${smp_pbty}_fsm_algo_${fsm_algo}_fsm_scorer_${fsm_scorer}"
                                # settings
                                content="$fold,$rand,all,"
                                if [[ $fsm_algo == hc ]]; then
                                    content+="$fsm_conf"
                                else
                                    content+="$fsm_nfeats"
                                fi
                                content+=",$focus"
                                # score
                                for smp in $samples; do
                                    for sc in precision recall; do
                                        sc_file=${fn}_${smp}_${sc}.stats
                                        sc_mean=$(grep_stat mean $sc_file)
                                        content+=",$sc_mean"
                                    done
                                done
                                # diversity
                                dfile=${fn}.diversity
                                dmean=$(grep_stat mean $dfile)
                                content+=",$dmean"
                                echo "$content"
                            done
                        done
                    done
                done
            done
        done
    done
done
