#!/bin/bash
#SBATCH --job-name=bakta
#SBATCH --output=/maps/projects/course_1/scratch/group_1/logs/bakta_%x_%j.out
#SBATCH --error=/maps/projects/course_1/scratch/group_1/logs/bakta_%x_%j.err
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=6G
#SBATCH --time=10:00:00
#SBATCH --reservation=NBIB25004U
#SBATCH --account=teaching

module load anaconda3/5.3.1

python scripts/12_1_bakta_AMR.py \ /maps/projects/course_1/scratch/group1/group-project-team-sheep/09_annotation_bakta_ref \ -o /maps/projects/course_1/scratch/group1/group-project-team-sheep/amr_plots

