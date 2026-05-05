#!/bin/bash
#can be run directly in terminal outside of SLURM

umask 0000

usage() {
	echo
	echo "Usage: $0 -a BINNING_DIR -b CHECKM2_DIR -o HQ_MAGS_DIR [-h]"
        echo
	echo "Options:"
        echo "  -a: Input directory containing all bins; ./all_bins see wiki"
	echo "  -b: Input checkm2 directory"
        echo "  -o: Output directory to be created"
        echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "a:b:o:h" opt; do
        case "$opt" in
                a)
                  	BINNING_DIR="$OPTARG"
                        ;;
                b)
                  	CHECKM2_DIR="$OPTARG"
                        ;;
                o)
                  	HQ_MAGS_DIR="$OPTARG"
                        ;;
                h)
                  	usage 0
                        ;;
                *)
                  	usage 1
                        ;;
        esac
done

if [[ -z "$BINNING_DIR" || -z "$CHECKM2_DIR" || -z "$HQ_MAGS_DIR" ]]; then
        usage 1
fi

mkdir -p ${HQ_MAGS_DIR}

# Pull HQ bin names (column 1 = Name, 2 = Completeness, 3 = Contamination)
awk -F'\t' 'NR>1 && ($2 - 5*$3) >= 50 { print $1 }' \
    ${CHECKM2_DIR}/quality_report.tsv \
    > ${HQ_MAGS_DIR}/hq_bin_names.txt

# See how many passed
wc -l ${HQ_MAGS_DIR}/hq_bin_names.txt

# Copy the corresponding FASTAs into the HQ folder
while read -r name; do
    cp ${BINNING_DIR}/all_bins/${name}.fa ${HQ_MAGS_DIR}/
done < ${HQ_MAGS_DIR}/hq_bin_names.txt
