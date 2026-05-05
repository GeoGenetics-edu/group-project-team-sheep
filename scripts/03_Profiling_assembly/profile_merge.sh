#!/bin/bash
#SBATCH --job-name=Profile_Merging                               # name shown in squeue  ^`^t can be anything
#SBATCH --output=/maps/projects/course_1/people/jdg143/logs/%x_%j.out   # stdout log
#SBATCH --error=/maps/projects/course_1/people/jdg143/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=10                                       # CPUs available to that task
#SBATCH --mem-per-cpu=8G                                         # RAM per CPU (total = cpus  ^w mem-per-cpu)
#SBATCH --time=03:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation
#SBATCH --account=teaching                                       # class billing account

module load metaphlan/4.1.1

usage() {
	echo
	echo "Usage: $0 -d DIR [-h]"
        echo
	echo "Options:"
        echo "  -d: Directory containing all samples"
        echo "  -h: show this message and exit"
        echo
	exit "$1"
}

while getopts "d:h" opt; do
        case "$opt" in
                d)
                  	DIR="$OPTARG"
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

merge_metaphlan_tables.py \
    ${DIR}/*/*/*_metaphlan.txt \
    > ${DIR}/merged_metaphlan_abd_table.txt
