#!/bin/bash
#SBATCH --job-name=Download_scr                                  # name shown in squeue. It can be anything.
#SBATCH --output=/maps/projects/course_1/people/jdg143/logs/%x_%j.out   # stdout log. Make sure to create your logs folder
#SBATCH --error=/maps/projects/course_1/people/jdg143/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=8                                        # CPUs available to that task
#SBATCH --mem-per-cpu=10G                                        # RAM per CPU (total = cpus * mem-per-cpu)
#SBATCH --time=01:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk                          # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation. Specific for this course. Bent reserved a node for us.
#SBATCH --account=teaching                                       # class billing account

#gut_adult: ERR2641635 ERR2641677 ERR2641733

#gut_infant: SRR8692206 SRR8692207 SRR8692213

#vaginal: SRR059458 SRR059459 SRR513791

module load sratoolkit

RAW_DIR="/maps/projects/course_1/scratch/group1/group-project-team-sheep/week18-preprocessing/data/01_raw_read"
THREADS=8

declare -a bp_arr=("gut_adult" "gut_infant" "vaginal")

for BODYSITE in "${bp_arr[@]}"
do
	case "${BODYSITE}" in
		gut_adult)
			ACCESIONS=(ERR2641635 ERR2641677 ERR2641733)
			;;
		gut_infant)
			ACCESIONS=(SRR8692206 SRR8692207 SRR8692213)
			;;
		vaginal)
			ACCESIONS=(SRR059458 SRR059459 SRR513791)
			;;
		*)
			exit 1
	esac

	mkdir -p "${RAW_DIR}/${BODYSITE}"

	for ACCESSION in "${ACCESSIONS[@]"
	do
		OUTDIR="${RAW_DIR}/${BODYSITE}/${ACCESSION}"
		mkdir -p "${OUTDIR}"

		VALIDATION_LOG="${OUTDIR}/${ACCESSION}_validation.log"
		# 1. Download the .sra archive
		prefetch ${ACCESSION} --max-size 1t -p -O ${RAW_DIR}/${BODYSITE}â

		# 2. Validate the download
		vdb-validate ${RAW_DIR}/${BODYSITE}/${ACCESSION}/${ACCESSION}.sra > "${VALIDATION_LOG}" 2>&1

		# 3. Extract to paired-end FASTQ
		fasterq-dump ${RAW_DIR}/${BODYSITE}/${ACCESSION}/${ACCESSION}.sra \
		    -e ${THREADS} \
		    -O ${RAW_DIR}/${BODYSITE}/${ACCESSION} \
		    -p
	done
done
