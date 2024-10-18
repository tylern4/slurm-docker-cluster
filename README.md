# Slurm Docker Cluster

This is a multi-container Slurm cluster using docker-compose.  The compose file
creates named volumes for persistent storage of MySQL data files as well as
Slurm state and log directories.

## Create the compose file

Once you have docker compose installed you should be able to create the compose file and test slurm.

```bash
python create_slurm.py
```
Start docker compose

```bash
docker compose -f docker-compose-workflow.yml up
```

In a different terminal you can login to the login node to start testing slurm.
```bash
docker exec -it login01 /bin/bash
[root@login01 /]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
regular*     up 5-00:00:00      5   idle node[01-05]
login        up 5-00:00:00      1   idle login01
[root@login01 /]#
```
