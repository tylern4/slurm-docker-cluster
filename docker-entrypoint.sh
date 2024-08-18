#!/bin/bash
set -e

echo "---> Starting the MUNGE Authentication service (munged) ..."
gosu munge /usr/sbin/munged

echo "---> Starting the slurmctld ..."
exec gosu slurm /usr/sbin/slurmctld -i -Dvvv > slurmctld.log 2>&1 &

echo "---> Waiting for slurmctld to become active before starting slurmd..."

echo "---> Starting the Slurm Node Daemon (slurmd) ..."
exec /usr/sbin/slurmd -Dvvv > slurmd.log 2>&1 &

cd /home/hpcuser
if [ "$#" -eq 0 ]; then
    exec gosu hpcuser /bin/bash -l
fi
echo "---> Running user command '${@}'"
exec gosu hpcuser "$@"
