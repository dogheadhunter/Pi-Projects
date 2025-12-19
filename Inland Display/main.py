"""Inland Display — starter script"""

import platform
import socket
import os
import sys
import time

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Pillow not found. Install with: sudo apt install python3-pil")
    sys.exit(1)

def rgb888_to_rgb565_bytes(img):
    """Convert PIL Image to RGB565 bytearray for framebuffer."""
    px = img.load()
    w, h = img.size
    out = bytearray()
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            v = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
            out += (v & 0xFF).to_bytes(1, 'little')
            out += ((v >> 8) & 0xFF).to_bytes(1, 'little')
    return out

def main():
    print("=" * 40)
    print("Inland Display — prototype")
    print("=" * 40)
    print(f"Hostname:    {socket.gethostname()}")
    print(f"OS System:   {platform.system()} {platform.release()}")
    print(f"Python Ver:  {platform.python_version()} ")
    print(f"Working Dir: {os.getcwd()}")
    print("=" * 40)

    fb_dev = '/dev/fb1'
    if not os.path.exists(fb_dev):
        print(f"Framebuffer {fb_dev} not found. Are you running on the Pi?")
        return

    print(f"Writing to {fb_dev}...")
    
    # Create image
    w, h = 480, 320
    img = Image.new('RGB', (w, h), '#003366')
    draw = ImageDraw.Draw(img)
    
    # Draw border
    draw.rectangle([0, 0, w-1, h-1], outline='#FFFFFF', width=5)
    
    # Draw text
    try:
        fnt = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 40)
        fnt_small = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 20)
    except IOError:
        fnt = ImageFont.load_default()
        fnt_small = ImageFont.load_default()

    msg = "Hello World!"
    # Use textbbox if available (Pillow >= 9.2), else fallback
    if hasattr(draw, 'textbbox'):
        bbox = draw.textbbox((0, 0), msg, font=fnt)
        tw, th = bbox[2]-bbox[0], bbox[3]-bbox[1]
    else:
        tw, th = draw.textsize(msg, font=fnt)
        
    draw.text(((w-tw)//2, (h-th)//2 - 20), msg, font=fnt, fill='#FFFFFF')

    footer = f"Host: {socket.gethostname()}"
    if hasattr(draw, 'textbbox'):
        bbox2 = draw.textbbox((0, 0), footer, font=fnt_small)
        fw, fh = bbox2[2]-bbox2[0], bbox2[3]-bbox2[1]
    else:
        fw, fh = draw.textsize(footer, font=fnt_small)
        
    draw.text(((w-fw)//2, h-50), footer, font=fnt_small, fill='#FFFF00')

    # Convert and write
    data = rgb888_to_rgb565_bytes(img)
    with open(fb_dev, 'wb') as f:
        f.write(data)
    
    print("Image written to display. Press Ctrl+C to exit.")
    
    # Keep the script running so the shell prompt doesn't overwrite the screen
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nExiting...")

if __name__ == "__main__":
    main()
