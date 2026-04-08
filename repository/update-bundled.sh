#!/usr/bin/env bash
# update-bundled.sh — pull latest code, rebuild frontend, restart containers
# Use this when running MySQL in the bundled Docker container (--profile bundled).
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
docker compose --profile bundled down

echo "==> Starting containers (build)..."
docker compose --profile bundled up -d --build

echo "==> Done. Checking health..."
sleep 3
docker compose ps
