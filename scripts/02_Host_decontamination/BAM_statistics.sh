#!/bin/bash
#SBATCH --job-name=BAM_statistics                                # name shown in squeue — can be anything
#SBATCH --output=/maps/projects/course_1/people/nrf382/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/people/nrf382/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=8                                        # CPUs available to that task
#SBATCH --mem-per-cpu=8G                                         # RAM per CPU (total = cpus × mem-per-cpu)
#SBATCH --time=03:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=efa@adm.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

module load samtools/1.21

THREADS=8
usage() {
	echo
	echo "Usage: $0 -a ACCESSION -d SAMPLE_PREP_DIR [-t Threads] [-h]"
	echo
	echo "Options:"
	echo "  -a: Accession name, e.g. SRR123456"
	echo "  -d: Directory containing Samples"
	echo "  -t: number of threads, default: 8"
	echo "  -h: show this message and exit"
	echo
	exit "$1"
}

while getopts "a:d:t:h" opt; do
	case "$opt" in
		a)
			ACCESSION="$OPTARG"
			;;
		d)
			SAMPLE_PREP="$OPTARG"
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

BAM=${SAMPLE_PREP}/${ACCESSION}.host.bam

samtools index    -@ ${THREADS} ${BAM}
samtools flagstat -@ ${THREADS} ${BAM} > ${SAMPLE_PREP}/${ACCESSION}.flagstat.txt
samtools idxstats -@ ${THREADS} ${BAM} > ${SAMPLE_PREP}/${ACCESSION}.idxstats.txt
samtools stats    -@ ${THREADS} ${BAM} > ${SAMPLE_PREP}/${ACCESSION}.stats.txt
