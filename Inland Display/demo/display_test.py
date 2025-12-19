#!/usr/bin/env python3
"""Display test pattern on a framebuffer (e.g., /dev/fb1 for the Inland TFT).

Usage: sudo python3 demo/display_test.py [--fb /dev/fb1] [--duration 10]

This script creates a 480x320 test pattern with text and writes it to the
framebuffer using 16-bit RGB565 format (common for ILI9486 drivers).
"""
import argparse
import os
import sys
import time

try:
    from PIL import Image, ImageDraw, ImageFont
except Exception:
    print("Pillow is not installed. Install with: sudo apt update && sudo apt install -y python3-pil")
    sys.exit(2)


def detect_fb(fbdev):
    if os.path.exists(fbdev):
        # Try to read size from sysfs
        base = os.path.dirname(fbdev)
        # common path: /sys/class/graphics/fb1/virtual_size
        try:
            fbname = os.path.basename(fbdev)
            sysfs = f"/sys/class/graphics/{fbname}/virtual_size"
            if os.path.exists(sysfs):
                with open(sysfs, "r") as f:
                    txt = f.read().strip()
                parts = txt.split(',')
                if len(parts) == 2:
                    w = int(parts[0]); h = int(parts[1])
                    return w, h
        except Exception:
            pass
        # fallback
        return 480, 320
    else:
        raise FileNotFoundError(f"Framebuffer device {fbdev} not found")


def rgb888_to_rgb565_bytes(img):
    # img is a PIL Image in RGB mode
    px = img.load()
    w, h = img.size
    out = bytearray()
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            # convert to 5-6-5
            v = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
            out += (v & 0xFF).to_bytes(1, 'little')
            out += ((v >> 8) & 0xFF).to_bytes(1, 'little')
    return out


def make_test_image(w, h, text=None):
    img = Image.new('RGB', (w, h), 'black')
    draw = ImageDraw.Draw(img)
    # gradient background
    for y in range(h):
        for x in range(0, w, 4):
            r = int(255 * x / max(1, w - 1))
            g = int(255 * y / max(1, h - 1))
            b = int(255 * (1 - x / max(1, w - 1)))
            draw.rectangle([x, y, min(w, x + 4), y + 1], fill=(r, g, b))
    # draw a rectangle and some text
    draw.rectangle([10, 10, w - 10, h - 10], outline=(255, 255, 255))
    fnt = None
    try:
        fnt = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 18)
    except Exception:
        fnt = ImageFont.load_default()
    msg = text or 'Inland Display — Test Pattern'
    tw, th = draw.textsize(msg, font=fnt)
    draw.text(((w - tw) // 2, (h - th) // 2), msg, font=fnt, fill=(255, 255, 255))
    return img


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--fb', default='/dev/fb1', help='Framebuffer device (e.g., /dev/fb1)')
    p.add_argument('--duration', type=int, default=8, help='Duration in seconds to show the pattern')
    p.add_argument('--text', default=None, help='Optional text to show on the pattern')
    args = p.parse_args()

    w, h = detect_fb(args.fb)
    print(f"Detected framebuffer {args.fb} => {w}x{h}")

    img = make_test_image(w, h, text=args.text)
    data = rgb888_to_rgb565_bytes(img)

    # Write to framebuffer
    print(f"Writing {len(data)} bytes to {args.fb} (this requires root)")
    with open(args.fb, 'wb') as f:
        f.write(data)
    # Keep the image on screen for a while
    try:
        time.sleep(args.duration)
    except KeyboardInterrupt:
        pass
    print('Done')
