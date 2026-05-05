#!/bin/bash
#SBATCH --job-name=Profiling_w_MetaPhlAn                         # name shown in squeue  ^`^t can be anything
#SBATCH --output=/maps/projects/course_1/people/nrf382/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/people/nrf382/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=11                                       # CPUs available to that task
#SBATCH --mem-per-cpu=8G                                         # RAM per CPU (total = cpus  ^w mem-per-cpu)
#SBATCH --time=03:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

module load metaphlan/4.1.1 bowtie2
METAPHLAN_INDEX="mpa_vJun23_CHOCOPhlAnSGB_202403"
METAPHLAN_DB_DIR="/maps/datasets/globe_databases/metaphlan/20241118"
THREADS=8


usage() {
	echo
	echo "Usage: $0 -a ACCESSION -d BODYPART -OUT_DIR [-t Threads] [-h]"
        echo
	echo "Options:"
        echo "  -a: Accession name, e.g. SRR123456"
        echo "  -d: Directory containing Samples"
	echo "  -o: Output Directory"
        echo "  -t: number of threads, default: 8"
        echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "a:d:t:o:h" opt; do
        case "$opt" in
                a)
                  	ACCESSION="$OPTARG"
                        ;;
                d)
                  	BODYSITE="$OPTARG"
                        ;;
		o)
			METAPHLAN_DIR="$OPTARG"
			;;
                t)
                  	THREADS="$OPTARG"
                        ;;
                h)
                  	usage 0
                        ;;
                *)
                  	usage 1
                        ;;
        esac
done

if [[ -z "ACCESSION" || -z "SAMPLE_PREP" ]]; then
        usage 1
fi
CLEAN_DIR=${BODYSITE}/${ACCESSION}/cleaned

METAPHLAN_OUT=${METAPHLAN_DIR}/$(basename "${BODYSITE}")/${ACCESSION}
mkdir -p ${METAPHLAN_OUT}

metaphlan \
    ${CLEAN_DIR}/${ACCESSION}_1_clean.fq.gz,${CLEAN_DIR}/${ACCESSION}_2_clean.fq.gz \
    --bowtie2out ${METAPHLAN_OUT}/${ACCESSION}.mapout.bz2 \
    --bowtie2db  ${METAPHLAN_DB_DIR} \
    --index      ${METAPHLAN_INDEX} \
    --nproc      ${THREADS} \
    --input_type fastq \
    -o ${METAPHLAN_OUT}/${ACCESSION}_metaphlan.txt
