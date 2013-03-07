#!/bin/bash

# Convert dataset.tab from alzheimers dir in a format parseable by
# MOSES

set -u
# set -x

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 dataset.tab"
    exit 1
fi

# Write header
header="out"
for gene in $(cut -f 1 "$1" | tail -n+2); do
    if [[ $gene =~ SNP_A* ]]; then
        gene_underscore=${gene//-/_}
        header+="\t$gene_underscore"
    fi
done
echo -e "$header"

# Write content
col_n=$(head -n 1 "$1" | wc -w)
col_n=$((col_n + 2))
for c in $(seq 3 $col_n); do
    for el in $(cut -f $c "$1"); do
        # target
        if [[ $el == "2" ]]; then
            content="1"
        elif [[ $el == "1" ]]; then
            content="0"
        fi
        # inputs
        if [[ $el == "0.75" || $el == "0.5" ]]; then
            content+="\t1"
        elif [[ $el == "0.25" || $el == "0.0" ]]; then
            content+="\t0"
        fi
    done
    echo -e "$content"
done
