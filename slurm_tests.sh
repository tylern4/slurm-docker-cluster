#!/bin/bash

echo "Testing sinfo"
sinfo

echo "Test sruns"
srun -N 1 -n 1 hostname
srun -N 2 -n 2 hostname


echo "Test Sbatch"
sbatch --wrap="hostname"

echo "Letting db catch up"
sleep 5
echo "Test sacct"
sacct 