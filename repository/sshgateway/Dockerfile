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

# Use tini as init to run both sshd and ssh_sync_daemon.py
CMD ["/sbin/tini", "--", "/bin/sh", "-c", \
    "python3 /app/ssh_sync_daemon.py &\n/usr/sbin/sshd -D -e"]
