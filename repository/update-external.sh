#!/usr/bin/env bash
# update-external.sh — pull latest code, rebuild frontend, restart containers
# Use this when connecting to an external (dedicated) MySQL server.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Pulling latest code..."
git pull

echo "==> Rebuilding frontend..."
cd frontend
npm install --silent
npm run generate
cd ..

echo "==> Stopping containers..."
docker compose down

echo "==> Starting containers (build)..."
docker compose up -d --build

echo "==> Done. Checking health..."
sleep 3
docker compose ps
