Title: Display limitation — Inland 3.5" SPI panel causes tearing/white-screen

Description:

- Hardware: Raspberry Pi (Bookworm) + Inland 3.5" TFT (ILI9486) on SPI
- Symptom: Tearing and occasional white-screen crashes when increasing SPI speed

Actions taken:
- Boosted SPI speeds (48MHz, 32MHz) — 48MHz caused white screen, 32MHz improved stability
- Boosted SPI driver and tested `fbcp` mirroring (HDMI -> SPI)
- Implemented pre-transcoding to 480x320 @12fps to reduce decoding and conversion workload
- Compiled and tested `fbcp-ili9341` (optimized driver) but it caused white-screen crashes on this panel

Result:
- Best stable setup is: pre-transcode (480x320 @12fps) + ffmpeg writing to fb0 + fbcp mirroring to SPI
- However, this is still suboptimal: occasional tearing persists and frame pacing is imperfect

Recommendation:
- Replace the display with an HDMI-capable screen or a SPI panel with proven higher-speed reliability
- If replacement isn't immediately available, keep using pre-transcoded low-framerate sources and avoid increasing SPI bus speed

Tags: hardware, display, help-wanted
