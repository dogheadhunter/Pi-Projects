Summary:

- Raspberry Pi + Inland 3.5" SPI TFT (ILI9486) shows tearing and occasional white-screen crashes when SPI speed is increased.
- Actions tried: fbcp mirroring (HDMI -> SPI), pre-transcoding videos to 480x320 @12fps, SPI speed tuning, and compiling/using fbcp-ili9341.
- Result: Best stable setup currently is pre-transcoding + fbcp mirroring; fbcp-ili9341 caused white-screen crashes on this panel.

Recommendation:

- Obtain an HDMI-capable display or a different SPI panel known to support higher SPI clock rates.
- If hardware change isn't possible, standardize on low-FPS pre-transcoded content (e.g., 12fps) and keep using fbcp mirroring.
