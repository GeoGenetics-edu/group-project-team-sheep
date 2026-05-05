#!/bin/bash
#SBATCH --job-name=MEGABAT_binning                               # name shown in squeue  ^`^t can be anything
#SBATCH --output=/maps/projects/course_1/people/nrf382/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/people/nrf382/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=15                                       # CPUs available to that task
#SBATCH --mem-per-cpu=10G                                        # RAM per CPU (total = cpus  ^w mem-per-cpu)
#SBATCH --time=05:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=efa@adm.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

umask 0000

module load bowtie2/2.4.2 samtools/1.21
export PATH=/opt/shared_software/shared_envmodules/conda/metabat2-2.17/bin:$PATH

THREADS=15
¢
usage() {
	echo
	echo "Usage: $0 -c CLEAN_DIR -d ASSEMBLY_DIR -o BINNING_DIR -b BODYSITE -a ACCESSION [-t] [-h]"
        echo
	echo "Options:"
        echo "  -c: Clean directory"
        echo "  -d: Assembly directory containing assembly from MEGAHIT"
	echo "  -o: Output directory for binnings to be created. "
        echo "  -b: Bodysite"
        echo "  -a: Accession number"
        echo "  -t: Threads, default: 15"
        echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "c:o:d:b:a:t:h" opt; do
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
		o)
		  BINNING_DIR="$OPTARG"
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

if [[ -z "CLEAN_DIR" ||  -z "BINNING_DIR" || -z "ASSEMBLY_DIR" || -z "BODYSITE" || -z "ACCESSION" ]]; then
        usage 1
fi

BODYSITE_NAME="$(basename "${BODYSITE}")"
ASM=${ASSEMBLY_DIR}/${BODYSITE_NAME}/${ACCESSION}/final.contigs.fa
SAMPLE_BIN=${BINNING_DIR}/${BODYSITE_NAME}/${ACCESSION}
mkdir -p ${SAMPLE_BIN}/bowtie2_index ${SAMPLE_BIN}/bins

# 8.1 Index the assembly
bowtie2-build --threads ${THREADS} ${ASM} ${SAMPLE_BIN}/bowtie2_index/${ACCESSION}

# 8.2 Map cleaned reads back to the assembly -> sorted BAM
bowtie2 -p ${THREADS} \
        -x ${SAMPLE_BIN}/bowtie2_index/${ACCESSION} \
        -1 ${CLEAN_DIR}/${ACCESSION}_1_clean.fq.gz \
        -2 ${CLEAN_DIR}/${ACCESSION}_2_clean.fq.gz \
    | samtools view -bS - \
    | samtools sort -@ ${THREADS} -o ${SAMPLE_BIN}/${ACCESSION}.bam -
samtools index ${SAMPLE_BIN}/${ACCESSION}.bam

# 8.3 Compute per-contig depth
jgi_summarize_bam_contig_depths \
    --outputDepth ${SAMPLE_BIN}/${ACCESSION}_metabat.depth \
    ${SAMPLE_BIN}/${ACCESSION}.bam

# 8.4 Run MetaBAT2
metabat2 \
    -i ${ASM} \
    -a ${SAMPLE_BIN}/${ACCESSION}_metabat.depth \
    -o ${SAMPLE_BIN}/bins/${ACCESSION}_bin \
    -m 1500 \
    -t ${THREADS} \
    --saveCls
