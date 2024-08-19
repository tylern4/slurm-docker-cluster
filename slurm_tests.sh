#!/bin/bash

set -e

echo "Testing sinfo"
sinfo

echo "Test sruns"
srun -N 1 -n 1 hostname

echo "Test Sbatch"
sbatch -N 1 -n 1 --wrap="hostname && sleep 10"
squeue
sleep 5 
squeue
