#!/usr/bin/env bash
# Usage: ./display-image.sh <IMAGE_PATH> <DURATION> <PI_HOST> [PI_USER]
# Example: ./display-image.sh myphoto.jpg 10 192.168.1.74
set -e

IMG=$1
DUR=$2
HOST=$3
USER=${4:-pi}

if [[ -z "$IMG" || -z "$DUR" || -z "$HOST" ]]; then
  echo "Usage: $0 <IMAGE_PATH> <DURATION> <PI_HOST> [PI_USER]"
  exit 1
fi

if [[ ! -f "$IMG" ]]; then
  echo "File not found: $IMG"
  exit 1
fi

FNAME=$(basename "$IMG")
REMOTE_PATH="/tmp/$FNAME"
REMOTE="$USER@$HOST"

echo "Sending $IMG to $REMOTE..."
scp "$IMG" "$REMOTE:$REMOTE_PATH"

echo "Displaying for $DUR seconds..."
ssh -t "$REMOTE" "which fbi >/dev/null || sudo apt-get install -y fbi; sudo killall fbcp 2>/dev/null; sudo killall fbi 2>/dev/null; sudo fbi -T 1 -d /dev/fb1 -noverbose -a $REMOTE_PATH >/dev/null 2>&1 & sleep $DUR; sudo killall fbi 2>/dev/null; sudo nohup fbcp >/dev/null 2>&1 &"
echo "Done."
