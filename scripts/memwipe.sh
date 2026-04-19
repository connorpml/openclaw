#!/usr/bin/env bash
# memwipe — reset ephemeral openclaw state (sessions, memory, task runs,
# sandboxes) while preserving config, credentials, skills, and model setup.
#
# Wipes:
#   ~/.openclaw/agents/main/sessions/*   (session transcripts + sessions.json)
#   ~/.openclaw/memory/main.sqlite       (agent memory DB)
#   ~/.openclaw/tasks/runs.sqlite*       (task run history)
#   ~/.openclaw/sandboxes/*              (stale sandbox dirs)
#
# Keeps: openclaw.json, agents/main/agent/ (auth/models), identity/,
#        credentials/, skills/, devices/, flows/, logs/.
#
# Assumes the stack is down (docker compose down) so sqlite files aren't held.
# Run with --force to skip the confirmation prompt.

set -euo pipefail

CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
# On Git Bash for Windows, $HOME is /c/Users/<you>; on mac/linux it's ~.
# If the user set OPENCLAW_CONFIG_DIR (as docker-compose does), honor that.

if [[ ! -d "$CONFIG_DIR" ]]; then
  echo "error: $CONFIG_DIR does not exist" >&2
  exit 1
fi

if [[ "${1:-}" != "--force" ]]; then
  echo "About to wipe ephemeral state in: $CONFIG_DIR"
  echo "  - agents/main/sessions/*"
  echo "  - memory/main.sqlite"
  echo "  - tasks/runs.sqlite*"
  echo "  - sandboxes/*"
  read -rp "Proceed? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "aborted."; exit 0; }
fi

rm -rf \
  "$CONFIG_DIR"/agents/main/sessions/* \
  "$CONFIG_DIR"/memory/main.sqlite \
  "$CONFIG_DIR"/tasks/runs.sqlite \
  "$CONFIG_DIR"/tasks/runs.sqlite-shm \
  "$CONFIG_DIR"/tasks/runs.sqlite-wal \
  "$CONFIG_DIR"/sandboxes/*

echo "neuralyzed."
