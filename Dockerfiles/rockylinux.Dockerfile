FROM rockylinux:9.3

LABEL org.opencontainers.image.source="https://github.com/tylern4/slurm-docker-cluster" \
    org.opencontainers.image.title="slurm-docker-cluster" \
    org.opencontainers.image.description="Slurm Docker cluster on Rocky Linux 8" \
    org.label-schema.docker.cmd="docker-compose up -d" \
    maintainer="tylern@nersc"

RUN set -ex \
    && dnf makecache \
    && dnf -y update \
    && dnf install -y epel-release \
    && dnf -y install dnf-plugins-core \
    && dnf config-manager --set-enabled crb \
    && dnf -y install \
    wget \
    openssh-server \
    bzip2 \
    perl \
    gcc \
    gcc-c++\
    git \
    gnupg \
    make \
    munge \
    munge-devel \
    python3-devel \
    python3-pip \
    python3 \
    mariadb-server \
    mariadb-devel \
    psmisc \
    bash-completion \
    vim-enhanced \
    http-parser-devel \
    json-c-devel \
    apptainer-suid \
    podman \
    openmpi-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN ssh-keygen -A
RUN groupadd -g 1000 hpcusers && useradd -rm -d /home/hpcuser -s /bin/bash -g 1000 -u 1000 hpcuser
RUN pip3 install Cython nose

ARG GOSU_VERSION=1.11
ARG TARGETARCH
RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-${TARGETARCH}" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-${TARGETARCH}.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ARG SLURM_TAG=slurm-24-05-0-1
RUN set -x \
    && git clone -b ${SLURM_TAG} --single-branch --depth=1 https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm \
    --with-mysql_config=/usr/bin  --libdir=/usr/lib64 \
    && make -j install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm \
    && groupadd -r --gid=990 slurm \
    && useradd -r -g slurm --uid=990 slurm \
    && mkdir -p /etc/sysconfig/slurm \
    /var/spool/slurmd \
    /var/run/slurmd \
    /var/lib/slurmd \
    /var/log/slurm \
    /data \
    && touch /var/lib/slurmd/node_state \
    /var/lib/slurmd/front_end_state \
    /var/lib/slurmd/job_state \
    /var/lib/slurmd/resv_state \
    /var/lib/slurmd/trigger_state \
    /var/lib/slurmd/assoc_mgr_state \
    /var/lib/slurmd/assoc_usage \
    /var/lib/slurmd/qos_usage \
    /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* \
    && /sbin/create-munge-key

COPY slurm/slurm.conf /etc/slurm/slurm.conf
COPY slurm/cgroup.conf /etc/slurm/cgroup.conf
RUN set -x \
    && chmod -R 777 /data

COPY slurm_tests.sh /usr/local/bin/slurm_tests.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/*.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
