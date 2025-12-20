import os
import time
import struct

FB_PATH = '/dev/fb1'
WIDTH = 480
HEIGHT = 320
BPP = 2 # 16-bit RGB565
FRAME_SIZE = WIDTH * HEIGHT * BPP

def main():
    print(f"Testing display on {FB_PATH}...")
    try:
        with open(FB_PATH, 'wb') as fb:
            # Create a red frame (RGB565 Red is 0xF800)
            # Little Endian: 0x00 0xF8
            red_pixel = b'\x00\xF8'
            red_frame = red_pixel * (WIDTH * HEIGHT)
            
            print("Writing RED frame...")
            fb.seek(0)
            fb.write(red_frame)
            fb.flush()
            time.sleep(2)
            
            # Create a Green frame (RGB565 Green is 0x07E0)
            # Little Endian: 0xE0 0x07
            green_pixel = b'\xE0\x07'
            green_frame = green_pixel * (WIDTH * HEIGHT)
            
            print("Writing GREEN frame...")
            fb.seek(0)
            fb.write(green_frame)
            fb.flush()
            time.sleep(2)
            
            # Create a Blue frame (RGB565 Blue is 0x001F)
            # Little Endian: 0x1F 0x00
            blue_pixel = b'\x1F\x00'
            blue_frame = blue_pixel * (WIDTH * HEIGHT)
            
            print("Writing BLUE frame...")
            fb.seek(0)
            fb.write(blue_frame)
            fb.flush()
            time.sleep(2)
            
    except PermissionError:
        print("Error: Permission denied. Run with sudo?")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
