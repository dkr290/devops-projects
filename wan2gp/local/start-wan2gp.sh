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

cd /workspace/Wan2GP

# Start Wan2gp directly on its working port 
SERVER_NAME="0.0.0.0"
SERVER_PORT="7860"

echo "Starting Wan2GP on $SERVER_NAME:$SERVER_PORT"
echo "Streaming logs to stdout (use 'docker logs -f wan2gp' to follow)..."

python3 wgp.py --server-name "$SERVER_NAME" --server-port "$SERVER_PORT" --save-masks &

WAN2GP_PID=$!

wait $WAN2GP_PID





