#!/bin/bash
#SBATCH --job-name=MEGAHIT_assembly                              # name shown in squeue  ^`^t can be anything
#SBATCH --output=/maps/projects/course_1/people/nrf382/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/people/nrf382/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=11                                       # CPUs available to that task
#SBATCH --mem-per-cpu=10G                                        # RAM per CPU (total = cpus  ^w mem-per-cpu)
#SBATCH --time=05:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

export PATH=/opt/shared_software/shared_envmodules/conda/megahit-1.2.9/bin:$PATH

THREADS=11

usage() {
	echo
	echo "Usage: $0 -c CLEAN_DIR -d ASSEMBLY_DIR -b BODYSITE -a ACCESSION [-t] [-h]"
        echo
	echo "Options:"
	echo "  -c: Clean directory"
        echo "  -d: Assembly directory. DO NOT USE SAMPLE DIRECTORY! (it will remove them)"
	echo "  -b: Bodysite"
        echo "  -a: Accession number"
	echo "  -t: Threads, default: 8"
	echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "c:d:b:a:t:h" opt; do
        case "$opt" in
		c)
			CLEAN_DIR="$OPTARG"
			;;
                d)
                  	ASSEMBLY_DIR="$OPTARG"
                        ;;
		b)
			BODYSITE="$OPTARG"
			;;
		a)
			ACCESSION="$OPTARG"
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

if [[ -z "CLEAN_DIR" || -z "ASSEMBLY_DIR" || -z "BODYSITE" || -z "ACCESSION" ]]; then
        usage 1
fi

BODYSITE_NAME="$(basename "${BODYSITE}")"
MEGAHIT_OUT=${ASSEMBLY_DIR}/${BODYSITE_NAME}/${ACCESSION}

mkdir -p ${ASSEMBLY_DIR}/${BODYSITE_NAME}

#Check if outdir exists and if it does remove it.
if [ -d ${MEGAHIT_OUT} ]; then
	rm -rf ${MEGAHIT_OUT}
fi

megahit \
    -t ${THREADS} \
    --min-contig-len 1500 \
    --verbose \
    -1 ${CLEAN_DIR}/${ACCESSION}_1_clean.fq.gz \
    -2 ${CLEAN_DIR}/${ACCESSION}_2_clean.fq.gz \
    -o ${MEGAHIT_OUT}




