#!/usr/bin/env bash
# Play a local video on a remote Pi's Inland display (/dev/fb1) via ffmpeg
# Usage:
#  ./scripts/play-video.sh --file /path/to/video.mp4 --host 192.168.1.74 [--user tonicdub] [--fps 12] [--duration full|SECONDS] [--save-encoded yes|no]

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --file FILE --host HOST [--user USER] [--fps FPS] [--duration full|SECONDS] [--save-encoded yes|no]

Options:
  --file           Local video file to play
  --host           Pi host/IP
  --user           SSH username (default: pi)
  --fps            Target frames-per-second on playback (default: 12)
  --duration       Playback duration in seconds, or "full" (default: full)
  --save-encoded   If "yes", keep the encoded file on the Pi (default: no)
EOF
  exit 1
}

# defaults
USER=pi
FPS=12
DURATION=full
SAVE_ENCODED=no

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) FILE="$2"; shift 2;;
    --host) HOST="$2"; shift 2;;
    --user) USER="$2"; shift 2;;
    --fps) FPS="$2"; shift 2;;
    --duration) DURATION="$2"; shift 2;;
    --save-encoded) SAVE_ENCODED="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

if [[ -z "${FILE:-}" || -z "${HOST:-}" ]]; then
  usage
fi

if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE" >&2
  exit 2
fi

if ! command -v ffmpeg >/dev/null; then
  echo "ffmpeg is required locally to transcode. Install it and retry." >&2
  exit 3
fi

BASENAME=$(basename "$FILE")
ENCODED="${BASENAME%.*}_480_f${FPS}.mp4"
TMPDIR=$(mktemp -d)
ENCODED_LOCAL="$TMPDIR/$ENCODED"
REMOTE_PATH="/tmp/$ENCODED"
REMOTE="${USER}@${HOST}"
FB_BS=$((480*320*2))

echo "Transcoding locally to 480px height @ ${FPS}fps -> $ENCODED_LOCAL"
ffmpeg -y -i "$FILE" -vf scale=480:-2,fps=${FPS} -c:v libx264 -profile:v baseline -level 3.0 -preset fast -crf 23 -pix_fmt yuv420p "$ENCODED_LOCAL"

echo "Copying encoded file to Pi: $REMOTE:$REMOTE_PATH"
scp "$ENCODED_LOCAL" "$REMOTE:$REMOTE_PATH"

# Build remote command
REMOTE_CMD="set -e; "
REMOTE_CMD+="sudo pkill -f fbcp || true; sudo pkill -f fbi || true; "
if [[ "$DURATION" != "full" ]]; then
  REMOTE_CMD+="sudo ffmpeg -re -t ${DURATION} -i $REMOTE_PATH -vf fps=${FPS} -pix_fmt rgb565le -f rawvideo - | sudo dd of=/dev/fb1 bs=${FB_BS} conv=notrunc; "
else
  REMOTE_CMD+="sudo ffmpeg -re -i $REMOTE_PATH -vf fps=${FPS} -pix_fmt rgb565le -f rawvideo - | sudo dd of=/dev/fb1 bs=${FB_BS} conv=notrunc; "
fi
REMOTE_CMD+="sudo pkill -f ffmpeg || true; sudo killall fbi 2>/dev/null || true; "
REMOTE_CMD+="sudo systemd-run --unit=fbcp-restore --service-type=simple fbcp >/dev/null 2>&1 || true; "
if [[ "$SAVE_ENCODED" != "yes" ]]; then
  REMOTE_CMD+="rm -f $REMOTE_PATH || true; "
fi

echo "Starting playback on Pi (this will disconnect after streaming completes)..."
# Use ssh -t to allow any sudo prompts
ssh -t "$REMOTE" "$REMOTE_CMD"

echo "Cleaning local temp files..."
rm -rf "$TMPDIR"

echo "Playback finished. If the screen did not return to the console, try restarting fbcp on the Pi."
exit 0
