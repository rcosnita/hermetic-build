FROM --platform=$TARGETARCH rcosnita/hermetic-demo:1.0.0-rocky-$TARGETARCH

USER root
RUN dnf install -y openssh-server gdb perf procps && \
    ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N '' && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "root:test" | chpasswd && \
    /usr/sbin/sshd

ADD cpp/build/scripts/remote-development-entrypoint.sh /remote-development-entrypoint.sh

RUN chmod u+x /remote-development-entrypoint.sh
ENTRYPOINT ["/remote-development-entrypoint.sh"]