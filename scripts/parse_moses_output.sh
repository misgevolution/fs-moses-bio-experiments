#!/bin/bash
#
# Parse a file output by MOSES (MOSESOUTPUT.moses) and generate N
# files in the same directory:
#
# MOSESOUTPUT_cnd_i.combo
# for i=0,...,N-1

if [[ $# != 1 ]]; then
    echo "Error: wrong number of command parameters"
    echo "Usage: $0 MOSES_OUTPUT"
    exit 1
fi

MO=$1

PROG_PATH=$(readlink -f "$0")
PROG_DIR=$(dirname "$PROG_PATH")
. $PROG_DIR/common.sh

###############
# Code itself #
###############

unpadded_m_i=0
while read result; do
    if [[ "$result" =~ n_evals.* ]]; then
        continue
    fi
    m_i=$(pad $unpadded_m_i $candidates_digits)
    cfile=$(chg_ext $(ibe ${MO} _cnd_${m_i}) combo)
    result="${result#* }" # remove score
    echo "$result" > "$cfile"
    ((unpadded_m_i++))
done < <(gawk 'NR % 6 == 1' < "$MO") # ignore lines 2-6 as only the
                                     # model is on the 1st line
