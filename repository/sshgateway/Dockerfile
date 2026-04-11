FROM alpine:3.19

RUN apk add --no-cache openssh python3 py3-pip tini shadow && \
    pip3 install --no-cache-dir flask --break-system-packages && \
    ssh-keygen -A && \
    echo '/usr/sbin/nologin' >> /etc/shells

# SSH server config
COPY sshd_config /etc/ssh/sshd_config

# SSH sync daemon (runs inside container alongside sshd)
COPY ssh_sync_daemon.py /app/ssh_sync_daemon.py
RUN chmod +x /app/ssh_sync_daemon.py

EXPOSE 22 9922

# Use tini as init to run both sshd and the sync daemon.
# The daemon restarts automatically if it exits (e.g. unexpected crash).
# It also waits internally for config.json to appear, so startup order is safe.
CMD ["/sbin/tini", "--", "/bin/sh", "-c", \
    "while true; do python3 /app/ssh_sync_daemon.py; echo 'Sync daemon exited, restarting in 5s...'; sleep 5; done &\n/usr/sbin/sshd -D -e"]
