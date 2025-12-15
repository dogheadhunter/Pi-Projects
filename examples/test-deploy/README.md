# Test Deployment

This is a simple script to verify that your deployment workflow is working.

## Usage

1. Deploy to your Pi:
   ```powershell
   .\scripts\deploy.ps1 -Path examples/test-deploy -Host <YOUR_PI_IP> -User <YOUR_USER>
   ```

2. SSH into your Pi and run it:
   ```bash
   python3 ~/projects/test-deploy/hello.py
   ```
