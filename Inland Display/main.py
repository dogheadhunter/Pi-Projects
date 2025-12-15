"""Inland Display — starter script"""

import platform
import socket
import os

print("=" * 40)
print("Inland Display — prototype")
print("=" * 40)
print(f"Hostname:    {socket.gethostname()}")
print(f"OS System:   {platform.system()} {platform.release()}")
print(f"Python Ver:  {platform.python_version()} ")
print(f"Working Dir: {os.getcwd()}")
print("=" * 40)

# TODO: Add display logic (graphics, images, web UI, etc.)
