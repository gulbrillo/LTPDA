#!/bin/sh
# LTPDA sshgateway entrypoint
# Generates SSH host keys on first run and stores them in the shared config volume
# so they survive image rebuilds — MATLAB users won't see host-key-changed warnings.
set -e

KEYDIR=/app/config/ssh_host_keys
mkdir -p "$KEYDIR"

if [ ! -f "$KEYDIR/ssh_host_ed25519_key" ]; then
    echo "Generating SSH host keys (first run)..."
    ssh-keygen -q -t ed25519 -f "$KEYDIR/ssh_host_ed25519_key" -N ''
fi
if [ ! -f "$KEYDIR/ssh_host_rsa_key" ]; then
    ssh-keygen -q -t rsa -b 4096 -f "$KEYDIR/ssh_host_rsa_key" -N ''
fi

chmod 600 "$KEYDIR"/ssh_host_*_key
chmod 644 "$KEYDIR"/ssh_host_*_key.pub

# Start the sync daemon with automatic restart on crash (background)
while true; do
    python3 /app/ssh_sync_daemon.py
    echo "Sync daemon exited — restarting in 5s..."
    sleep 5
done &

# sshd in foreground (tini handles signals + zombie reaping)
exec /usr/sbin/sshd -D -e
