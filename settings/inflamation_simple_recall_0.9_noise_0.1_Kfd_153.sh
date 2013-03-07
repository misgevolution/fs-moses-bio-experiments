######################
# General parameters #
######################

# data set
dataset=../data/O100.MOSES

# directory name of the experiment
exp_dir=bio_simple_recall_0.9_noise_0.1_Kfd_153

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
nfeats_seq=({10..30..10})
# nfeats_seq=(20)

##########################################
# Feature selection with MOSES parameter #
##########################################
fsm_nfeats_seq=({2..20..2})
# fsm_nfeats_seq=({2..4..2})
focus_seq=(all active)
# focus_seq=(all active incorrect ai)
# seed_seq=(none add init xmplr)
seed_seq=(init)
# fsm_algo_seq=(simple hc)
fsm_algo_seq=(simple)
# smp_pbty_seq=($(seq 0.1 0.1 0.9))
smp_pbty_seq=(0.1)
fsm_scorer_seq=(mi)
# scorer_seq=(mi pre)
smd_threshold=0.000001
inc_red_intensity=0.1
hc_evals=10000
hc_conf=100
