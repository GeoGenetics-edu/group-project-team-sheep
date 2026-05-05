#!/bin/bash
#SBATCH --job-name=Bin_quality_Check2M                           # name shown in squeue  ^`^t can be anything
#SBATCH --output=/maps/projects/course_1/people/nrf382/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/people/nrf382/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=25                                       # CPUs available to that task
#SBATCH --mem-per-cpu=4G                                         # RAM per CPU (total = cpus  ^w mem-per-cpu)
#SBATCH --time=05:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

export PATH=/opt/shared_software/shared_envmodules/conda/checkm2-1.0.2/bin:$PATH

umask 0000

THREADS=25
CHECKM2_DB=/maps/datasets/globe_databases/checkm2/20250215/CheckM2_database/uniref100.KO.1.dmnd

usage() {
	echo
	echo "Usage: $0 -i BINNING_DIR -o CHECKM2_DIR [-t THREADS] [-h]"
        echo
	echo "Options:"
        echo "  -i: Input directory containing all bins; ./all_bins see wiki"
	echo "  -o: Output directory to be created"
        echo "  -t: Threads, default: 25"
        echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "i:o:t:h" opt; do
        case "$opt" in
                i)
                  	BINNING_DIR="$OPTARG"
                        ;;
                o)
                  	CHECKM2_DIR="$OPTARG"
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

if [[ -z "$BINNING_DIR" || -z "$CHECKM2_DIR" ]]; then
        usage 1
fi


#Check if outdir exists and if it does remove it.
if [ -d "${CHECKM2_DIR}" ]; then
        rm -rf "${CHECKM2_DIR}"
fi

checkm2 predict \
    --threads     "${THREADS}" \
    --input       "${BINNING_DIR}/all_bins" \
    --output-directory "${CHECKM2_DIR}" \
    --database_path    "${CHECKM2_DB}" \
    -x fa

