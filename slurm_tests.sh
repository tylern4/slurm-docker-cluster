#!/bin/bash

set -e

echo "Testing sinfo"
sinfo

echo "Test sruns"
srun -N 1 -n 1 hostname

echo "Test Sbatch"
sbatch -N 1 -n 1 --wrap="hostname && sleep 10"
sleep 10
for i in {0..2}; do
    squeue
    sleep 10
done
