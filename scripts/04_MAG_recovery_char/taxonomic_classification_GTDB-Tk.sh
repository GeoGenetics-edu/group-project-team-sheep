#!/bin/bash
#SBATCH --job-name=Taxa                           # name shown in squeue  ^`^t can be anything
#SBATCH --output=/maps/projects/course_1/scratch/group1/group-project-team-sheep/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/scratch/group1/group-project-team-sheep/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=30                                       # CPUs available to that task
#SBATCH --mem-per-cpu=10G                                        # RAM per CPU (total = cpus  ^w mem-per-cpu)
#SBATCH --time=10:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

umask 0000

module load gtdbtk/2.7.1
export GTDBTK_DATA_PATH=/maps/projects/course_1/data/gtdb232/release232

THREADS=30

usage() {
	echo
	echo "Usage: $0 -i HQ_MAGS_DIR -o GTDBTK_DIR [-t THREADS] [-h]"
        echo
	echo "Options:"
        echo "  -i: Input directory containing only high quality MAGs"
        echo "  -o: Output directory to be created"
        echo "  -t: Threads, default: 30"
        echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "i:o:t:h" opt; do
        case "$opt" in
                i)
                  	HQ_MAGS_DIR="$OPTARG"
                        ;;
                o)
                  	GTDBTK_DIR="$OPTARG"
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

if [[ -z "$HQ_MAGS_DIR" || -z "$GTDBTK_DIR" ]]; then
        usage 1
fi

#Check if outdir exists and if it does remove it.
if [[ -d "${GTDBTK_DIR}" ]]; then
        rm -rf "${GTDBTK_DIR}"
fi

gtdbtk classify_wf \
    --genome_dir "${HQ_MAGS_DIR}" \
    --out_dir    "${GTDBTK_DIR}" \
    --cpus       "${THREADS}" \
    --extension  fa \
    --place_species
