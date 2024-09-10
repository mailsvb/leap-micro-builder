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

FROM opensuse/tumbleweed:latest AS final

COPY --chown=root:root --chmod=777 run.sh /run.sh
COPY --from=base /leap.iso /leap.iso
COPY --from=base /leap /leap
COPY --from=base /xorriso /usr/local

RUN zypper install --no-confirm jq git

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
