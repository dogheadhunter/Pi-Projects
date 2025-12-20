Project Status

Summary
- Project: Mini TV using Raspberry Pi + Inland 3.5" TFT (SPI)
- Status: Current dead end due to display hardware and driver limitations.

Findings
- The SPI-driven Inland 3.5" screen experiences tearing and occasional white-screen crashes when bus speed is increased.
- Using fbcp mirroring (HDMI -> SPI) + pre-transcoding videos to 480x320 @12fps reduces tearing but is not perfect.
- Attempted optimized driver (`fbcp-ili9341`) but the driver instabilities caused white-screen crashes on this exact panel.

Next steps / Suggestions
- Obtain an HDMI-capable display or a different SPI panel known to work reliably at higher speeds.
- If replacing hardware is not possible, consider using lower frame rates and pre-transcoding all content.

Notes
- Project with rasberry pi at current dead end. Need better display with hdmi out.
