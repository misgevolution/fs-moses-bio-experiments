fs-moses-bio-experiments
========================

Set of scripts to run some feature selection within MOSES bio experiments

Requirements
------------

- csvtool (should be available in your distro repository), otherwise
  https://forge.ocamlcore.org/projects/csv/

- OpenCog (in particular moses and feature-selection). You can use the
  latest version on github https://github.com/opencog/opencog
  Or, to be sure that you can reproduce the experiments the revision
  4581cf94d9e7c19f1577d76e2b0a20735c668347

Installation
------------

Compile and install OpenCog, see http://wiki.opencog.org/w/Building_OpenCog

Usage
-----

1. Copy your data file(s) under

<fs-moses-bio-experiments>/data

your data file(s) must be in a TSV format (Tab Seperated Value). The
first column is the target variable. The other columns are the
inputs. The first row is the header (output and input names), and the
following rows the observations.

2. Set your setting file(s)

Fill a setting file with your experimental settings and place it under
directory

<fs-moses-bio-experiments>/settings

You may find examples in that directory

3. Run experiment

go under the directory

<fs-moses-bio-experiments>/experiments

and run

../scripts/run_exp.sh ../settings/MY_SETTINGS &> MY_EXP.log

That script is gonna create a directory $exp_dir as specified in the
setting file and place a bunch of intermediary files under it produced
during the experiment.

4. Analyze experiment

still under

<fs-moses-bio-experiments>/experiments

../scripts/anal_exp.sh ../settings/MY_SETTINGS &> MY_EXP_ANALYSIS.log

That script is gonna create more intermediary files and finally under
$exp_dir 2 files

results.csv, the results in terms of precision, recall and diversity
of all experiments.

avg_results.csv, averaging of results.csv across all folds and random
seeds.
