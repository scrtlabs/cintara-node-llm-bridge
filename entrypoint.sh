#!/usr/bin/env bash
set -euo pipefail
MODE="${RUN_MODE:-start}"
HOME_DIR="${CINTARA_HOME:-/data/.tmp-cintarad}"
if [ "$MODE" = "init" ]; then
  mkdir -p "$HOME_DIR"
  echo "[cintara] Init complete. Home at $HOME_DIR"
  sleep infinity
  exit 0
fi
exec cintarad start --home "$HOME_DIR"