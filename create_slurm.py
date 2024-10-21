import sys
import yaml
import json
from pathlib import Path

login_template = """{nodename}:
  image: {image_name}
  command: ["slurmd"]
  hostname: {nodename}
  container_name: {nodename}
  volumes:
    - etc_munge:/etc/munge
    - etc_slurm:/etc/slurm
    - slurm_jobdir:/data
    - var_log_slurm:/var/log/slurm
    - ./ssh:/home/hpcuser/.ssh
    - ./slurm/slurm.conf:/etc/slurm/slurm.conf:ro
    - ./slurm/slurmdbd.conf:/etc/slurm/slurmdbd.conf:ro
  expose:
    - "6818"
  depends_on:
    - "slurmctld" """


node_template = """{nodename}:
  image: {image_name}
  command: ["slurmd"]
  hostname: {nodename}
  container_name: {nodename}
  volumes:
    - etc_munge:/etc/munge
    - etc_slurm:/etc/slurm
    - slurm_jobdir:/data
    - var_log_slurm:/var/log/slurm
    - ./ssh:/home/hpcuser/.ssh
    - ./slurm/slurm.conf:/etc/slurm/slurm.conf:ro
    - ./slurm/slurmdbd.conf:/etc/slurm/slurmdbd.conf:ro
  expose:
    - "6818"
  depends_on:
    - "slurmctld"
    - "login01"
    """


compose_template = """services:
  mysql:
    image: mariadb:10.10
    hostname: mysql
    container_name: mysql
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
      MYSQL_DATABASE: slurm_acct_db
      MYSQL_USER: slurm
      MYSQL_PASSWORD: password
    volumes:
      - var_lib_mysql:/var/lib/mysql

  slurmdbd:
    image: {image_name}
    command: ["slurmdbd"]
    container_name: slurmdbd
    hostname: slurmdbd
    volumes:
      - etc_munge:/etc/munge
      - etc_slurm:/etc/slurm
      - var_log_slurm:/var/log/slurm
    expose:
      - "6819"
    depends_on:
      - mysql

  slurmctld:
    image: {image_name}
    command: ["slurmctld"]
    container_name: slurmctld
    hostname: slurmctld
    volumes:
      - etc_munge:/etc/munge
      - etc_slurm:/etc/slurm
      - slurm_jobdir:/data
      - var_log_slurm:/var/log/slurm
      - ./slurm/slurm.conf:/etc/slurm/slurm.conf:ro
      - ./slurm/slurmdbd.conf:/etc/slurm/slurmdbd.conf:ro
    expose:
      - "6817"
    depends_on:
      - "slurmdbd"

  login01:
    image: {image_name}
    command: ["slurmd"]
    hostname: login01
    container_name: login01
    volumes:
      - etc_munge:/etc/munge
      - etc_slurm:/etc/slurm
      - slurm_jobdir:/data
      - var_log_slurm:/var/log/slurm
      - ./ssh:/home/hpcuser/.ssh
      - ./slurm/slurm.conf:/etc/slurm/slurm.conf:ro
      - ./slurm/slurmdbd.conf:/etc/slurm/slurmdbd.conf:ro
    expose:
      - "6818"
      - "22"
    depends_on:
      - "slurmctld"

volumes:
  etc_munge:
  etc_slurm:
  slurm_jobdir:
  var_lib_mysql:
  var_log_slurm:
"""


if len(sys.argv) > 1:
    image = sys.argv[1]
else:
    image = "ghcr.io/tylern4/slurm:slurm-24-05-0-1-rockylinux9"


compose = yaml.safe_load(compose_template.format(image_name=image))

for node_num in range(5):
    if node_num > 100:
        print("Too many nodes!")
        continue
    node = node_template.format(nodename=f"node{node_num+1:02}", image_name=image)
    compose['services'].update(yaml.safe_load(node))

output = Path('docker-compose-workflow.yml')
with output.open('w') as outfile:
    yaml.safe_dump(compose, outfile)

print(f"saved {output}")
