import yaml
import json
from pathlib import Path

login_template = """{nodename}:
  image: slurm-docker-cluster:23.11.6
  command: ["slurmd"]
  hostname: {nodename}
  container_name: {nodename}
  volumes:
    - etc_munge:/etc/munge
    - etc_slurm:/etc/slurm
    - slurm_jobdir:/data
    - var_log_slurm:/var/log/slurm
    - ./ssh:/home/hpcuser/.ssh
    - ./slurm.conf:/etc/slurm/slurm.conf:ro
    - ./slurmdbd.conf:/etc/slurm/slurmdbd.conf:ro
  expose:
    - "6818"
  depends_on:
    - "slurmctld" """


node_template = """{nodename}:
  image: slurm-docker-cluster:23.11.6
  command: ["slurmd"]
  hostname: {nodename}
  container_name: {nodename}
  volumes:
    - etc_munge:/etc/munge
    - etc_slurm:/etc/slurm
    - slurm_jobdir:/data
    - var_log_slurm:/var/log/slurm
    - ./ssh:/home/hpcuser/.ssh
    - ./slurm.conf:/etc/slurm/slurm.conf:ro
    - ./slurmdbd.conf:/etc/slurm/slurmdbd.conf:ro
  expose:
    - "6818"
  depends_on:
    - "slurmctld"
    - "login01"
    """

compose_file = Path("docker-compose.yml.temp")
with compose_file.open('r') as nt:
    compose = yaml.safe_load(nt)


for node_num in range(5):
    if node_num > 100:
        print("Too many nodes!")
        continue
    node = node_template.format(nodename=f"node{node_num+1:02}")
    compose['services'].update(yaml.safe_load(node))

with open('docker-compose.yml', 'w') as outfile:
    yaml.safe_dump(compose, outfile)
