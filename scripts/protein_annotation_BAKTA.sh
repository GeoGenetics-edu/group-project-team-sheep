#!/bin/bash
#SBATCH --job-name=Protein_annotation_w.BAKT                     # name shown in squeue  ^`^t can be anything
#SBATCH --output=/maps/projects/course_1/scratch/group1/group-project-team-sheep/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/scratch/group1/group-project-team-sheep/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=6                                        # CPUs available to that task
#SBATCH --mem-per-cpu=6G                                         # RAM per CPU (total = cpus  ^w mem-per-cpu)
#SBATCH --time=10:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

export PATH=/opt/shared_software/shared_envmodules/conda/bakta-1.11.3/bin:$PATH

DB="/maps/projects/course_1/data/dbcan_db"
THREADS=6

usage() {
	echo
	echo "Usage: $0 -i HQ_MAGS_DIR -o GTDBTK_DIR [-t THREADS] [-h]"
        echo
	echo "Options:"
        echo "  -i: Input directory containing only high quality MAGs"
        echo "  -o: Output directory to be created"
        echo "  -t: Threads, default: 6"
        echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "i:o:t:h" opt; do
        case "$opt" in
                i)
                  	INPUT_DIR="$OPTARG"
                        ;;
                o)
                  	OUT_DIR="$OPTARG"
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

if [[ -z "$INPUT_DIR" || -z "$OUT_DIR" ]]; then
        usage 1
fi

mkdir -p "$OUT_DIR"

mapfile -t BINS < <(ls "$INPUT_DIR"/*.fa 2>/dev/null | sort)

for bin in "${BINS[@]}"; do
    sample=$(basename "$bin" .fa)
    sample_out="$OUT_DIR/$sample"

    # Skip if already annotated
    if [[ -s "$sample_out/$sample.gff3" ]]; then
        continue
    fi

    mkdir -p "$sample_out"

    bakta \
        --threads 6 \
        --db "$DB" \
        --compliant \
        --verbose \
        --force \
        --prefix "$sample" \
        --output "$sample_out" \
        "$bin"
done

