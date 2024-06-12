#!/bin/bash
set -x

echo "Testing sinfo"
sinfo

echo "Test sruns"
srun -N 1 -n 1 hostname
srun -N 2 -n 2 hostname

echo "Test sacct"
sacct 