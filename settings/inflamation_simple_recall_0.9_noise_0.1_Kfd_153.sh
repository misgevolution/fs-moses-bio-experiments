######################
# General parameters #
######################

# data set
dataset=../data/O100.MOSES

# directory name of the experiment
exp_dir=inflamation_simple_recall_0.9_noise_0.1_Kfd_153

# K-fold cross validation
Kfd=153
# Kfd=3

# rand_seq=({1..10})
rand_seq=(1)

jobs=4

# number of candidate per moses execution
candidates=10

# To only experiment without fsm (to search an interesting experiment)
no_fsm=false

######################
# Learning parameter #
######################
scorer=prerec
perm_ratio=1.0
# ctemp=0.00001
ctemp=2
hardness=1
recall_min=0.9
evals=10000
# evals=100
noise=0.1
revisit=0

######################
# Diversity pressure #
######################
dpressure=0.1
dexp=1
dst=tanimoto

##########################
# Pre Feature selection  #
##########################
pfs_algo=inc
conf_seq=(100)                  # for inc and simple
nfeats_seq=({10..30..10})       # for inc and simple
# nfeats_seq=(1)                  # for hc
# conf_seq=(0.1 0.2 0.3)       # for hc

##########################################
# Feature selection with MOSES parameter #
##########################################
prune=0
fsm_nfeats_seq=({2..20..2})     # for inc and simple
fsm_conf_seq=(1.0)           # for inc and simple
# fsm_nfeats_seq=(1)                        # for hc
# fsm_conf_seq=(2.0)            # for hc
focus_seq=(all active)
# focus_seq=(all active incorrect ai)
# seed_seq=(none add init xmplr)
seed_seq=(init)
fsm_algo=hc
# smp_pbty_seq=($(seq 0.1 0.1 0.9))
smp_pbty_seq=(0.1)
fsm_scorer_seq=(mi)
# scorer_seq=(mi pre)
smd_threshold=0.000001
inc_red_intensity=0.1
hc_evals=10000
hc_widen_search=0
hc_crossover=1
hc_crossover_pop_size=120
breadth_first=1
