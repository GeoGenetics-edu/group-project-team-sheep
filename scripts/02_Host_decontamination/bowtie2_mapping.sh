#!/bin/bash
#SBATCH --job-name=BowTie2_mapping                               # name shown in squeue — can be anything
#SBATCH --output=/maps/projects/course_1/people/jdg143/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/people/jdg143/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=20                                       # CPUs available to that task
#SBATCH --mem-per-cpu=10G                                        # RAM per CPU (total = cpus × mem-per-cpu)
#SBATCH --time=03:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

module load bowtie2/2.4.2 samtools/1.21

THREADS=8
HOST_INDEX_DIR=/maps/projects/course_1/data/human_genome_db/hg38

usage() {
    echo
    echo "Usage: $0 -a ACCESSION -d SAMPLE_PREP_DIR [-t THREADS]"
    echo
    echo "Options:"
    echo "  -a  Accession name, e.g. SRR123456"
    echo "  -d  Directory containing trimmed FASTQ files"
    echo "  -t  Number of threads, default: 8"
    echo "  -h  Show this message and exit."
    echo
    exit "$1"
}

while getopts "a:d:t:" opt; do
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

if [[ -z "$ACCESSION" || -z "$SAMPLE_PREP" ]]; then
    usage 1
fi

bowtie2 -x ${HOST_INDEX_DIR}/hg38 \
        -1 ${SAMPLE_PREP}/${ACCESSION}_1.trimmed.fastq.gz \
        -2 ${SAMPLE_PREP}/${ACCESSION}_2.trimmed.fastq.gz \
        -p ${THREADS} \
        2> ${SAMPLE_PREP}/${ACCESSION}.bowtie2.log \
    | samtools view -bS -@ ${THREADS} - \
    | samtools sort  -@ ${THREADS} -o ${SAMPLE_PREP}/${ACCESSION}.host.bam -

