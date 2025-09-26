FROM ubuntu:25.04

LABEL org.opencontainers.image.source="https://github.com/tylern4/slurm-docker-cluster" \
    org.opencontainers.image.title="slurm-docker-cluster" \
    org.opencontainers.image.description="Slurm Docker cluster on Ubuntu" \
    maintainer="tylern@nersc.gov"

RUN set -ex \
    && apt-get update \
    && apt-get -y install \
    wget \
    openssh-server \
    bzip2 \
    perl \
    gcc \
    g++ \
    git \
    gnupg \
    make \
    munge \
    libmunge2 \
    libmunge-dev \
    python3-dev \
    python3-pip \
    python3 \
    libmariadb-dev \
    psmisc \
    libopenmpi-dev

RUN ssh-keygen -A
RUN groupadd -g 1001 hpcusers && useradd -rm -d /home/hpcuser -s /bin/bash -g 1001 -u 1001 hpcuser
RUN pip3 install --break-system-packages Cython nose

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

ARG SLURM_TAG=slurm-25-05-3-1
SHELL ["/bin/bash", "-c"]
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
    && mkdir -p /run/munge \
    && chown munge:munge /run/munge \
    && chmod 0755 /run/munge

COPY slurm/slurm.conf /etc/slurm/slurm.conf
COPY slurm/cgroup.conf /etc/slurm/cgroup.conf
RUN set -x \
    && chmod -R 777 /data

COPY slurm_tests.sh /usr/local/bin/slurm_tests.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/*.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
