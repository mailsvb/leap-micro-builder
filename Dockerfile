ARG iso_type

FROM opensuse/tumbleweed:latest AS base

RUN zypper install --no-confirm gcc make awk && \
    curl -OL https://www.gnu.org/software/xorriso/xorriso-1.5.7.tar.gz && \
    tar -zxvf xorriso-1.5.7.tar.gz && \
    cd /xorriso-1.5.7 && \
    ./configure --prefix=/xorriso && \
    make && \
    make install

RUN curl -L https://download.opensuse.org/distribution/leap-micro/6.0/appliances/iso/openSUSE-Leap-Micro.x86_64-Default-SelfInstall.iso -o /leap.iso && \
    mkdir -p /leap && \
    /xorriso/bin/osirrox -indev /leap.iso -extract / /leap

RUN curl -L https://download.opensuse.org/distribution/leap-micro/6.0/product/iso/openSUSE-Leap-Micro-6.0-x86_64.iso -o /packages.iso && \
    mkdir -p /packages && \
    /xorriso/bin/osirrox -indev /packages.iso -extract / /packages

FROM opensuse/tumbleweed:latest AS final-core

COPY --chown=root:root --chmod=777 run.sh /run.sh
COPY --from=base /leap.iso /leap.iso
COPY --from=base /leap /leap
COPY --from=base /xorriso /usr/local

FROM opensuse/tumbleweed:latest AS final-full

COPY --chown=root:root --chmod=777 run.sh /run.sh
COPY --from=base /leap.iso /leap.iso
COPY --from=base /leap /leap
COPY --from=base /packages/noarch/*.rpm /leap/packages/
COPY --from=base /packages/x86_64/*.rpm /leap/packages/
COPY --from=base /xorriso /usr/local

FROM final-${iso_type} AS final

RUN zypper install --no-confirm jq git

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
