#!/bin/bash
set -e

echo "=== Wan2GP Container Startup ==="

# Restore application files if needed (handles volume mount scenario)
if [ ! -f "/workspace/Wan2GP/wgp.py" ]; then
    echo "Restoring application files..."
    mkdir -p /workspace/Wan2GP
    rsync -a /opt/wan2gp_source/ /workspace/Wan2GP/
    echo "Application files restored"
else
    echo "Application files already present"
fi


# Start our application in the background
echo "Starting Wan2GP application in background..."
cd /workspace/Wan2GP

# Start Wan2gp directly on its working port 
SERVER_NAME="0.0.0.0"
SERVER_PORT="7860"

echo "Starting Wan2GP on $SERVER_NAME:$SERVER_PORT"
nohup python3 wgp.py --server-name $SERVER_NAME --server-port $SERVER_PORT --save-masks > /workspace/wan2gp.log 2>&1 &
echo "Wan2GP started on internal port $SERVER_PORT, logs in /workspace/wan2gp.log"

echo "Starting RunPod services..."
if [ -f "/start.sh" ]; then
    /start.sh
else
    echo "No /start.sh found, keeping container alive by monitoring log for debugging."
    tail -f /workspace/wan2gp.log
fi 
