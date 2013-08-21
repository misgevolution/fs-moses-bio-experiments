fs-moses-bio-experiments
========================

Set of scripts to run some feature selection within MOSES bio experiments

Requirements
------------

- stats, you must compile it yourself, follow the instructions below
    - mkdir stats; cd stats # create a stats directory on your machine
    - wget http://web.cs.wpi.edu/~claypool/misc/stats/stats.tgz # download stats.tgz
    - tar xvzf stats.tgz # unpack it
    - make # compile
    - sudo cp stats /usr/bin # copy to your system binary dir

- csvtool (should be available in your distro repository), otherwise
  https://forge.ocamlcore.org/projects/csv/

- OpenCog (in particular moses and feature-selection). You can use the
  latest version on github https://github.com/opencog/opencog
  Or, to be sure that you can reproduce the experiments the revision
  beca40c6e1de86550e751db86138921fdb193d9d

Installation
------------

Compile and install OpenCog, see http://wiki.opencog.org/w/Building_OpenCog

Usage
-----

### 1. Copy your data file(s) under

    <fs-moses-bio-experiments>/data
    
your data file(s) must be in a TSV format (Tab Seperated Value). The
first column is the target variable. The other columns are the
inputs. The first row is the header (output and input names), and the
following rows the observations.

### 2. Set your setting file(s)
Fill a setting file with your experimental settings and place it under
directory

    <fs-moses-bio-experiments>/settings
    
You may find examples in that directory

### 3. Run experiment

Create a directory for your experiments

    mkdir MY_EXPERIMENTS
    cd MY_EXPERIMENTS

for instance besides the project directory <fs-moses-bio-experiments>, and run

    <fs-moses-bio-experiments>/scripts/run_exp.sh <fs-moses-bio-experiments>/settings/MY_SETTINGS &> MY_EXP.log

That script is gonna create a directory $exp_dir as specified in the
setting file and place a bunch of intermediary files under it produced
during the experiment.

### 4. Analyze experiment

while still under

    MY_EXPERIMENTS
    
run

    <fs-moses-bio-experiments>/scripts/anal_exp.sh <fs-moses-bio-experiments>/settings/MY_SETTINGS &> MY_EXP_ANALYSIS.log

That script is gonna create a directory

    MY_EXPERIMENTS/anal

and fill it with intermediary files, and finally under $exp_dir, 2
files:

1. results.csv, the results in terms of precision, recall and
diversity of all experiments.

2. avg_results.csv, averaging of results.csv across all folds and
random seeds.
