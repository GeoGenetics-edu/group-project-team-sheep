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

usage() {
	echo
	echo "Usage: $0 [-h]"
        echo
	echo "Options:"
        echo "  -: "
        echo "  -: "
        echo "  -: "
        echo "  -h: "
        echo
	exit "$1"
}

while getopts "" opt; do
        case "$opt" in
                )
                  	="$OPTARG"
                        ;;
                )
                  	="$OPTARG"
                        ;;
                )
                  	="$OPTARG"
                        ;;
                h)
                  	usage 0
                        ;;
                *)
                  	usage 1
                        ;;
        esac
done

if [[ -z  || -z  ]]; then
        usage 1
fi
