#!/bin/bash
#
# Series of experiments on biological data

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 SETTINGS_FILE"
    exit 1
fi

set -u

# Source settings
. $1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

# Sanity checks
if [[ ${#nfeats_seq[@]} != 1 && ${#conf_seq[@]} != 1 ]]; then
    echo "At least one of nfeats_seq or conf_seq must have only 1 element"
    exit 1
fi
if [[ ${#fsm_nfeats_seq[@]} != 1 && ${#fsm_conf_seq[@]} != 1 ]]; then
    echo "At least one of fsm_nfeats_seq or fsm_conf_seq must have only 1 element"
    exit 1
fi

#################################
# Create experiment directories #
#################################
mkdir -p $exp_dir/data          # data sets
mkdir -p $exp_dir/res           # moses results
mkdir -p $exp_dir/log           # moses logs

###########################################################
# Copy dataset and generate k-fold cross validation files #
###########################################################
cp $dataset $exp_dir/data
bnd=$(basename $dataset)
$PROG_DIR/kfold.sh $exp_dir/data/$bnd $Kfd

########################
# Experiment main loop #
########################

n_exp=$((${#nfeats_seq[@]} * ${#conf_seq[@]} * Kfd))
if [[ $no_fsm == false ]]; then
    n_exp=$((n_exp + Kfd * ${#fsm_nfeats_seq[@]} * ${#fsm_conf_seq[@]} * ${#focus_seq[@]} * ${#seed_seq[@]} * ${#smp_pbty_seq[@]} * ${#fsm_scorer_seq[@]}))
fi

ei=0
CMD="moses"
for fd in $(seq 1 $Kfd); do
    ar=$fd

    echo
    echo "~~~~ validation $fd/$Kfd ~~~~"
        
    baseif=${bnd}.train_${fd}to${Kfd}
    ifile=$exp_dir/data/$baseif

    # general program options
    GPO="-r $ar -j $jobs -l debug -V 1 -W 1 -x 1 -t 1 -c $candidates"

    # learning program options
    LPO="-H $scorer"
    LPO+=" --hc-allow-resize-deme 0"
    LPO+=" -m $evals"
    LPO+=" -p $noise"
    LPO+=" -v $ctemp"
    LPO+=" --alpha $hardness"
    LPO+=" -q $recall_min"
    LPO+=" --logical-perm-ratio $perm_ratio"
    LPO+=" --revisit $revisit"

    # diversity
    LPO+=" --diversity-pressure $dpressure"
    LPO+=" --diversity-exponent $dexp"
    LPO+=" --diversity-dst $dst"
        
    #####################
    # Learning (no fsm) #
    #####################

    for nfeats in ${nfeats_seq[@]}; do
        for conf in ${conf_seq[@]}; do
            ((ei++))
            message="~~~~ Learning (no fsm, "
            if [[ $pfs_algo == hc ]]; then
                message+="pre-conf = $conf"
            else
                message+="pre-nfeats = $nfeats"
            fi
            message+=", $ei/$n_exp) ~~~~"
            echo
            echo "$message"
            date

            learn_base_name_no_fs="fd_${fd}to${Kfd}_"
            if [[ $pfs_algo == hc ]]; then
                learn_base_name_no_fs+="conf_${conf}"
            else
                learn_base_name_no_fs+="nfeats_${nfeats}"
            fi
            learn_base_name_no_fs+="_no_fsm"

            # pre-filter dataset
            filtered_file="${ifile}_filtered_"
            if [[ $pfs_algo == hc ]]; then
                filtered_file+="conf_${conf}"
            else
                filtered_file+="nfeats_${nfeats}"
            fi
            fs_lfile=$exp_dir/log/feature_selection_${learn_base_name_no_fs}.log
            FCMD="feature-selection"

            FPO="-a $pfs_algo"
            if [[ $pfs_algo == hc ]]; then
                FPO+=" --mi-penalty -$conf"
                FPO+=" --max-evals $hc_evals"
                FPO+=" --hc-crossover $hc_crossover"
                FPO+=" --hc-crossover-pop-size $hc_crossover_pop_size"
            else
                FPO+=" --target-size $nfeats"
            fi
            FPO+=" -i $ifile -o $filtered_file -j $jobs -F $fs_lfile -l debug"

            echo "$FCMD $FPO"
            $FCMD $FPO

            # specific program options to the experiment
            rfile="$exp_dir/res/${learn_base_name_no_fs}.moses"
            lfile="$exp_dir/log/${learn_base_name_no_fs}.log"
            SPO="-i $filtered_file -o $rfile -f $lfile"
            
            echo "$CMD $GPO $LPO $SPO"
            $CMD $GPO $LPO $SPO
            done
    done
    
    ##################
    # Learning (fsm) #
    ##################
    if [[ $no_fsm == true ]]; then
        continue            # skip fsm experiments
    fi
        
    for fsm_nfeats in ${fsm_nfeats_seq[@]}; do
        for fsm_conf in ${fsm_conf_seq[@]}; do
            for focus in ${focus_seq[@]}; do
                for seed in ${seed_seq[@]}; do
                    for smp_pbty in ${smp_pbty_seq[@]}; do
                        for fsm_scorer in ${fsm_scorer_seq[@]}; do
                            ((ei++))
                            message="~~~~ Learning (feature selection"
                            if [[ $fsm_algo == hc ]]; then
                                message+=" fsm_conf = $fsm_conf,"
                            else
                                message+=" fsm_nfeats = $fsm_nfeats,"
                            fi
                            message+=" focus = $focus, seed = $seed, smp_pbty = $smp_pbty, fsm_algo = $fsm_algo, fsm_scorer = $fsm_scorer, $ei/$n_exp) ~~~~"
                            echo
                            echo "$message"
                            date
                            learn_base_name="fd_${fd}to${Kfd}_"
                            if [[ $fsm_algo == hc ]]; then
                                learn_base_name+="fsm_conf_${fsm_conf}"
                            else
                                learn_base_name+="fsm_nfeats_${fsm_nfeats}"
                            fi
                            learn_base_name+="_focus_${focus}_seed_${seed}_smp_pbty_${smp_pbty}_fsm_algo_${fsm_algo}_fsm_scorer_${fsm_scorer}"
                            rfile=$exp_dir/res/${learn_base_name}.moses
                            lfile=$exp_dir/log/${learn_base_name}.log
                            
                            CMD="moses"
                            
                            # general program options
                            SPO="-i $ifile -o $rfile -f $lfile"
                            
                            # feature selection program options
                            FSPO="--enable-fs 1"

                            # algo
                            FSPO+=" --fs-algo $fsm_algo"
                            if [[ $fsm_algo == smd ]]; then
                                FSPO+=" --fs-threshold $smd_threshold"
                            elif [[ $fsm_algo == inc ]]; then
                                FSPO+=" --fs-inc-redundant-intensity $inc_red_intensity"
                            elif [[ $fsm_algo == hc ]]; then
                                FSPO+=" --fs-hc-max-evals $hc_evals"
                                FSPO+=" --fs-mi-penalty -$fsm_conf"
                                FSPO+=" --fs-hc-widen-search $hc_widen_search"
                                FSPO+=" --fs-hc-crossover $hc_crossover"
                                FSPO+=" --fs-hc-crossover-pop-size $hc_crossover_pop_size"
                            fi
                                
                            # scorer
                            FSPO+=" --fs-scorer $fsm_scorer"
                            if [[ $scorer == pre ]]; then
                                FSPO+=" --fs-pre-penalty $pre_penalty"
                                FSPO+=" --fs-pre-min-activation $pre_min_activation"
                            fi
                            FSPO+=" --fs-target-size $fsm_nfeats"
                            # focus
                            FSPO+=" --fs-focus $focus"
                            # seed
                            FSPO+=" --fs-seed $seed"
                            # Subsampling
                            FSPO+=" --fs-subsampling-pbty $smp_pbty"
                            # Prune exemplar
                            FSPO+=" --fs-prune-exemplar $prune"
                            # Number of demes for breadth-first search
                            FSPO+=" --fs-demes $breadth_first"

                            echo "$CMD $GPO $SPO $LPO $FSPO"
                            $CMD $GPO $SPO $LPO $FSPO
                        done
                    done
                done
            done
        done
    done
done
