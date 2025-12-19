# Inland 3.5" TFT LCD Touch Screen Monitor (Setup & Troubleshooting)

**SKU:** 632693 (Micro Center)  
**Controller:** ILI9486 (SPI) + XPT2046 (Touch)  
**Resolution:** 480×320 (3:2 aspect ratio)

This display connects via the GPIO header (SPI interface). It is known to be tricky to set up on newer Raspberry Pi OS versions (Bookworm/Bullseye) because it requires specific kernel overlays or drivers.

## ⚠️ Important Compatibility Note
- **Raspberry Pi OS Bookworm (Debian 12):** The traditional `LCD-show` drivers often break the desktop environment (Wayland/Wayfire).
- **Recommendation:** Use **Raspberry Pi OS Legacy (Buster/Bullseye)** or switch Bookworm to X11 backend if you encounter issues.

---

## Method 1: The "LCD-show" Driver (Easiest for Legacy OS)
This is the official method recommended by the manufacturer (LCDWiki/GoodTFT). It works best on **Raspberry Pi OS Legacy (Buster)** or **Bullseye**.

1.  **Connect the display** to the GPIO header (ensure pins align correctly starting at pin 1).
2.  **Boot your Pi** and SSH in.
3.  **Download and run the driver script:**

    ```bash
    sudo rm -rf LCD-show
    git clone https://github.com/goodtft/LCD-show.git
    chmod -R 755 LCD-show
    cd LCD-show/
    sudo ./LCD35-show
    ```

4.  The Pi will reboot automatically. After reboot, the display should work.

### Rotating the Screen
If the orientation is wrong, run one of these commands (rotates 90°, 180°, or 270°):
```bash
cd LCD-show/
sudo ./rotate.sh 90   # Options: 0, 90, 180, 270
```

---

## Method 2: Manual Config (Better for Newer OS / Bookworm)
If the script above breaks your system (black screen or boot loop), try this manual method using the built-in `dtoverlay`.

1.  **Edit config.txt:**
    ```bash
    sudo nano /boot/firmware/config.txt
    # (On older OS, it might be /boot/config.txt)
    ```

2.  **Add the following lines** to the end of the file:
    ```ini
    # Enable SPI
    dtparam=spi=on
    
    # Inland 3.5" TFT (ILI9486 based)
    dtoverlay=piscreen,speed=16000000,rotate=90
    
    # Alternative overlay if 'piscreen' fails:
    # dtoverlay=rpi-display,speed=16000000,rotate=90
    ```

3.  **Reboot:** `sudo reboot`

---

## Troubleshooting

### "The screen is white and nothing shows up"
- **Cause:** Driver not loaded or SPI not enabled.
- **Fix:** Ensure the display is seated firmly. Try Method 1. If that fails, re-image your SD card with "Raspberry Pi OS Legacy" and try Method 1 again.

### "The touch function is inverted"
- You may need to calibrate the screen.
- Install calibrator: `sudo apt install xinput-calibrator`
- Run `DISPLAY=:0 xinput_calibrator` (if using X11).

### "I lost my HDMI output"
- The `LCD-show` script forces output to the LCD and often disables HDMI.
- **To restore HDMI:**
    ```bash
    cd LCD-show/
    sudo ./LCD-hdmi
    ```

### "My desktop won't start on Bookworm"
- Bookworm uses Wayland by default, which doesn't play nice with these older SPI displays.
- **Fix:** Switch to X11.
    1. Run `sudo raspi-config`
    2. Go to **Advanced Options** > **Wayland**
    3. Select **X11**
    4. Reboot and try installing the driver again.

## Installer scripts (optional)

If you prefer an automated helper, this repo includes two scripts you can run from your workstation that will SSH to the Pi and install the recommended driver (or apply the manual dtoverlay):

- `scripts/install-inland-display.sh` (Linux / macOS)
- `scripts/install-inland-display.ps1` (Windows PowerShell)
- `scripts/check-display.sh` — small remote check helper to verify framebuffer and overlay state

Usage examples:

```bash
# Run the installer (default installs LCD-show driver)
./scripts/install-inland-display.sh <PI_HOST> [PI_USER]

# Use the safer manual method (adds overlay + enables SPI)
./scripts/install-inland-display.sh <PI_HOST> [PI_USER] --manual

# Quick remote check
./scripts/check-display.sh <PI_HOST> [PI_USER]
```

**Notes & safety:**
- These scripts use SSH; ensure you can `ssh pi@<PI_HOST>` from your machine (key-based auth recommended).
- The `LCD-show` script may reboot the Pi and can temporarily disable HDMI output. Back up important data first.

## Resources
- [LCDWiki Documentation (MPI3501)](http://www.lcdwiki.com/3.5inch_RPi_Display)
- [GitHub Driver Repository](https://github.com/goodtft/LCD-show)
