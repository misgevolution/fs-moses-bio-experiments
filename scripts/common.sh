####################
# useful functions #
####################

# Takes 2 arguments
#
# 1) a file name
#
# 2) a string to happens to the name before the extension.
#
# For instance
# $(ibe alibaba.csv _40_thiefs)
# returns alibaba_40_thiefs.csv
ibe() {
    local filename=$1
    local suffix=$2
    local ext_filename=${filename##*.}
    local woext_filename=${filename%.*}
    local result_filename=${woext_filename}${suffix}.$ext_filename
    echo $result_filename
}

# change the extension of a file name. The first argument is the file
# name and the second argument is the extension of replacement.
chg_ext() {
    local filename="$1"
    local extension="${filename##*.}"
    local filename_without_extension="${filename%.*}"
    local new_extension=$2
    echo ${filename_without_extension}.$new_extension
}

# pad $1 symbol with up to $2 0s
pad() {
    pad_expression="%0${2}d"
    printf "$pad_expression" "$1"    
}

# get the unique list of prefixes of file names starting by $1, ending
# by $2, excluding that ending
uniq_prefixes() {
    for ef in ${1}*$2; do
        echo ${ef%$2}
    done | sort -u
}

# get the unique list of suffixes starting by $1, ending by $2,
# excluding that start
uniq_suffixes() {
    for ef in ${1}*$2; do
        echo ${ef#$1}
    done | sort -u
}

# takes 2 files
#
# $1: actual
# $2: prediction
# $3: target feature
#
# Return the precision
precision() {
    local actual=($(csvtool -t TAB namedcol $3 $1))
    local as=${#actual[@]}
    local prediction=($(csvtool namedcol $3 $2))
    local pos=0
    local tp=0
    for i in $(seq 0 $((as - 1))); do
        if [[ ${prediction[$i]} == 1 ]]; then
            ((pos++))
            if [[ ${actual[$i]} == 1 ]]; then
                ((tp++))
            fi
        fi
    done
    bc -l <<< "$tp/$pos"
}

# takes 2 files
#
# $1: actual
# $2: prediction
# $3: target feature
#
# Return the recall
recall() {
    local actual=($(csvtool -t TAB namedcol $3 $1))
    local as=${#actual[@]}
    local prediction=($(csvtool namedcol $3 $2))
    local trues=0
    local tp=0
    for i in $(seq 0 $((as - 1))); do
        if [[ ${actual[$i]} == 1 ]]; then
            ((trues++))
            if [[ ${prediction[$i]} == 1 ]]; then
                ((tp++))
            fi
        fi
    done
    bc -l <<< "$tp/$trues"
}

# Given
#
# $1: stat, like mean, max, min
# $2: a file output file the tool stats
#
# return the value corresponding to the stat
grep_stat() {
    grep $1 $2 | sed 's/ //g' | cut -d":" -f2
}

# given a csv file $1, compute the mean of feature $3 to $# by group
# of features $2 (seperated by comma)
mean_group() {
    local file="$1"
    local group_features="$2"
    # write header
    local header="$2"
    shift 2
    for f in $@; do
        header+=",$f"
    done
    echo $header
    # write content
    local groups=$(csvtool namedcol $group_features $file | sort -u)
    for g in $groups; do
        local content="$g"
        local lines=$(head -n1 $file; grep $g $file)
        for f in $@; do
            local means=$(csvtool namedcol $f <(echo "$lines"))
            local st=$(stats <<< "$means")
            local mean=$(grep mean <<< "$st" | sed 's/ //g' | cut -d":" -f2)
            content+=",$mean"
        done
        echo $content
    done
}

# append CSV files without duplicating the header
appendCSVFiles() {
    head -n 1 "$1"
    for a_i in $(seq 1 $#); do
        tail -n +2 ${!a_i}
    done
}

# commands for parallelizing work
readonly PPAR="parallel -j$jobs -k -v" # pipe in the commands
readonly XPAR="parallel -j$jobs --xapply -k" # build commands with arguments
