#!/bin/bash
#SBATCH --job-name=scr_Download                                  # name shown in squeue. It can be anything.
#SBATCH --output=/maps/projects/course_1/people/jdg143/logs/%x_%j.out   # stdout log. Make sure to create your logs folder
#SBATCH --error=/maps/projects/course_1/people/jdg143/logs/%x_%j.err    # stderr log
#SBATCH --ntasks=1                                               # one task (one process group)
#SBATCH --cpus-per-task=10                                       # CPUs available to that task
#SBATCH --mem-per-cpu=10G                                        # RAM per CPU (total = cpus * mem-per-cpu)
#SBATCH --time=03:00:00                                          # HH:MM:SS wall-clock limit
#SBATCH --mail-type=end                                          # email me when it finishes
#SBATCH --mail-type=fail                                         # email me if it fails
#SBATCH --mail-user=jdg143@alumni.ku.dk	                         # your KU email
#SBATCH --reservation=NBIB25004U                                 # class reservation. Specific for this course. Bent reserved a node for us.
#SBATCH --account=teaching                                       # class billing account

module load sratoolkit

#gut_adult: ERR2641635 ERR2641677 ERR2641733

#gut_infant: SRR8692206 SRR8692207 SRR8692213

#vaginal: SRR059458 SRR059459 SRR513791

RAW_DIR = '/projects/course_1/scratch/group1/group-project-team-sheep/week18-preprocessing/data/01_raw_read/
BODYSITE = 'gut_adult'
ACCESSION = ERR2641635
THREADS = 6
¢
# 1. Download the .sra archive
prefetch ${ACCESSION} --max-size 1t -p -O ${RAW_DIR}/${BODYSITE}

# 2. Validate the download
vdb-validate ${RAW_DIR}/${BODYSITE}/${ACCESSION}/${ACCESSION}.sra > "${VALIDATION_LOG}" 2>&1

# 3. Extract to paired-end FASTQ
fasterq-dump ${RAW_DIR}/${BODYSITE}/${ACCESSION}/${ACCESSION}.sra \
    -e ${THREADS} \
    -O ${RAW_DIR}/${BODYSITE}/${ACCESSION} \
    -p


