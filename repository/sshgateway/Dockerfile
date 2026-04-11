FROM alpine:3.19

RUN apk add --no-cache openssh python3 py3-pip tini shadow && \
    pip3 install --no-cache-dir flask --break-system-packages && \
    echo '/usr/sbin/nologin' >> /etc/shells
# NOTE: host keys are NOT generated here — entrypoint.sh generates them at
# runtime and stores them in the ./config volume so they persist across rebuilds.

# SSH server config
COPY sshd_config /etc/ssh/sshd_config

# SSH sync daemon + entrypoint
COPY ssh_sync_daemon.py /app/ssh_sync_daemon.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /app/ssh_sync_daemon.py /entrypoint.sh

EXPOSE 22 9922

# tini as PID 1 for proper signal handling and zombie reaping
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
