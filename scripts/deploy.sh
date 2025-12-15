#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path-to-deploy> [pi_host] [pi_user]"
  exit 2
fi

LOCAL_PATH="$1"
PI_HOST="${2:-${PI_HOST:-}}"
PI_USER="${3:-${PI_USER:-pi}}"

if [ -z "$PI_HOST" ]; then
  echo "Set PI_HOST env var or pass as second argument"
  exit 2
fi

TARGET="$PI_USER@$PI_HOST:~/projects/$(basename "$LOCAL_PATH")"

echo "Deploying $LOCAL_PATH -> $TARGET"
scp -r "$LOCAL_PATH" "$TARGET"
ssh "$PI_USER@$PI_HOST" "echo 'Deployed to' ~/projects/$(basename "$LOCAL_PATH")"

echo "Done"