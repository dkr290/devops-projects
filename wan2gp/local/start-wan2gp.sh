#!/bin/bash
set -e

echo "=== Wan2GP Container Startup ==="

# CUDA debugging - helps identify kernel errors on different GPUs
export CUDA_LAUNCH_BLOCKING=1
export TORCH_USE_CUDA_DSA=1


# Log GPU info for debugging
echo "=== GPU Information ==="
nvidia-smi --query-gpu=name,compute_cap,memory.total --format=csv,noheader 2>/dev/null || echo "nvidia-smi not available"
echo ""


# Restore application files if needed (handles volume mount scenario)
if [ ! -f "/workspace/Wan2GP/wgp.py" ]; then
    echo "Restoring application files..."
    mkdir -p /workspace/Wan2GP
    rsync -a /opt/wan2gp_source/ /workspace/Wan2GP/
    echo "Application files restored"
else
    echo "Application files already present"
fi

# Create log directory
mkdir -p /workspace/logs
LOG_FILE="/workspace/logs/wan2gp_$(date +%Y%m%d_%H%M%S).log"

# Start our application in the background
echo "Starting Wan2GP application in background..."
cd /workspace/Wan2GP

# Start Wan2gp directly on its working port 
SERVER_NAME="0.0.0.0"
SERVER_PORT="7860"

echo "Starting Wan2GP on $SERVER_NAME:$SERVER_PORT"
echo "Log file: $LOG_FILE"
echo "Also streaming to stdout..."

# Use tee to log to file AND stdout simultaneously
python3 wgp.py --server-name "$SERVER_NAME" --server-port "$SERVER_PORT" --save-masks 2>&1 | tee "$LOG_FILE" &
WAN2GP_PID=$!

echo "Wan2GP started with PID $WAN2GP_PID"

# Symlink latest log for convenience
ln -sf "$LOG_FILE" /workspace/logs/wan2gp_latest.log


# echo "Starting Wan2GP on $SERVER_NAME:$SERVER_PORT"
# nohup python3 wgp.py --server-name $SERVER_NAME --server-port $SERVER_PORT --save-masks > /workspace/wan2gp.log 2>&1 &
# echo "Wan2GP started on internal port $SERVER_PORT, logs in /workspace/wan2gp.log"
#
# echo "Starting RunPod services..."
# if [ -f "/start.sh" ]; then
#     /start.sh
# else
#     echo "No /start.sh found, keeping container alive by monitoring log for debugging."
#     tail -f /workspace/wan2gp.log
# fi 

echo "Starting RunPod services..."
if [ -f "/start.sh" ]; then
    /start.sh
else
    echo "No /start.sh found, waiting for Wan2GP process..."
    wait $WAN2GP_PID
fi

