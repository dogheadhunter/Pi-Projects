import sys
import os
import time

FB_PATH = '/dev/fb1'
WIDTH = 480
HEIGHT = 320
BPP = 2 # 16-bit RGB565
FRAME_SIZE = WIDTH * HEIGHT * BPP

def read_exactly(stream, n):
    data = b''
    while len(data) < n:
        chunk = stream.read(n - len(data))
        if not chunk:
            break
        data += chunk
    return data

def main():
    sys.stderr.write(f"Starting stream to {FB_PATH} ({WIDTH}x{HEIGHT}, {BPP} bytes/pixel)\n")
    frame_count = 0
    try:
        with open(FB_PATH, 'wb') as fb:
            while True:
                # Read exactly one frame from stdin
                data = read_exactly(sys.stdin.buffer, FRAME_SIZE)
                
                if not data:
                    sys.stderr.write("End of stream (no data).\n")
                    break
                
                if len(data) < FRAME_SIZE:
                    sys.stderr.write(f"Incomplete frame received ({len(data)} bytes). Stopping.\n")
                    break
                
                # Seek to beginning of framebuffer
                fb.seek(0)
                # Write the frame
                fb.write(data)
                # Flush to ensure it appears immediately
                fb.flush()
                
                frame_count += 1
                if frame_count % 30 == 0:
                    sys.stderr.write(f"Displayed frame {frame_count}\r")
                    
    except BrokenPipeError:
        sys.stderr.write("Broken pipe.\n")
    except KeyboardInterrupt:
        sys.stderr.write("Interrupted.\n")
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
