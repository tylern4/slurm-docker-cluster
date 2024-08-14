#!/bin/bash

set -e

cd /data

echo "Testing sinfo"
sinfo

echo "Test sruns"
srun -N 1 -n 1 hostname
srun -N 2 -n 2 hostname


echo "Test Sbatch"
sbatch --wrap="hostname"

echo "Test podman"
srun -N 1 -n 1 podman run --rm -it hello-world:latest
sbatch --wrap="podman run --rm -it hello-world:latest"

echo "Test Apptainer"
srun -N 1 -n 1 apptainer run docker://hello-world
sbatch --wrap="apptainer run docker://hello-world"

echo "Letting db catch up"
sleep 5
echo "Test sacct"
sacct 