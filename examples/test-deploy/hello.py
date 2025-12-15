import socket
import platform
import os
import sys

print("=" * 40)
print("DEPLOYMENT SUCCESSFUL!")
print("=" * 40)
print(f"Hostname:    {socket.gethostname()}")
print(f"OS System:   {platform.system()} {platform.release()}")
print(f"Python Ver:  {sys.version.split()[0]}")
print(f"Working Dir: {os.getcwd()}")
print("=" * 40)
