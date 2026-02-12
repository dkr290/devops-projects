# ============================================================
# SwarmUI for RunPod
# ============================================================
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git wget build-essential \
  python3.11 python3.11-venv python3.11-dev python3-pip \
  ffmpeg libglib2.0-0 libgl1 \
  && rm -rf /var/lib/apt/lists/*

# Clone SwarmUI
RUN git clone https://github.com/mcmonkeyprojects/SwarmUI.git /SwarmUI

WORKDIR /SwarmUI

# Git safety for container
RUN git config --global --add safe.directory '*'

# Remove any pre-built binaries (will rebuild at launch)
RUN rm -rf ./src/bin ./src/obj

# ============================================================
# RunPod entrypoint script
# ============================================================
RUN cat <<'RUNPOD_ENTRY' > /SwarmUI/launchtools/runpod-entrypoint.sh
#!/usr/bin/env bash
set -e

cd /SwarmUI

# ── Persistent storage via RunPod network volume ──
# RunPod mounts network volume at /workspace
# We symlink key directories so data survives pod restarts

WORKSPACE="/workspace"

# Create workspace subdirs if they don't exist
mkdir -p "$WORKSPACE/SwarmUI/Models"
mkdir -p "$WORKSPACE/SwarmUI/Output"
mkdir -p "$WORKSPACE/SwarmUI/Data"
mkdir -p "$WORKSPACE/SwarmUI/dlbackend"
mkdir -p "$WORKSPACE/SwarmUI/DLNodes"
mkdir -p "$WORKSPACE/SwarmUI/Extensions"
mkdir -p "$WORKSPACE/SwarmUI/CustomWorkflows"

# Function: link a directory to workspace persistence
link_dir() {
    local CONTAINER_PATH="$1"
    local WORKSPACE_PATH="$2"

    # If it's already a symlink, skip
    if [ -L "$CONTAINER_PATH" ]; then
        return
    fi

    # If the container path exists and workspace is empty, seed it
    if [ -d "$CONTAINER_PATH" ] && [ -z "$(ls -A "$WORKSPACE_PATH" 2>/dev/null)" ]; then
        echo "Seeding $WORKSPACE_PATH from $CONTAINER_PATH"
        cp -a "$CONTAINER_PATH/." "$WORKSPACE_PATH/"
    fi

    # Remove container dir and symlink to workspace
    rm -rf "$CONTAINER_PATH"
    ln -sf "$WORKSPACE_PATH" "$CONTAINER_PATH"
    echo "Linked $CONTAINER_PATH -> $WORKSPACE_PATH"
}

link_dir "/SwarmUI/Models" "$WORKSPACE/SwarmUI/Models"
link_dir "/SwarmUI/Output" "$WORKSPACE/SwarmUI/Output"
link_dir "/SwarmUI/Data" "$WORKSPACE/SwarmUI/Data"
link_dir "/SwarmUI/dlbackend" "$WORKSPACE/SwarmUI/dlbackend"
link_dir "/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/DLNodes" "$WORKSPACE/SwarmUI/DLNodes"
link_dir "/SwarmUI/src/Extensions" "$WORKSPACE/SwarmUI/Extensions"
link_dir "/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/CustomWorkflows" "$WORKSPACE/SwarmUI/CustomWorkflows"

# ── Set fake home (same as official docker-standard-inner.sh) ──
export HOME=/SwarmUI/dlbackend/linuxhome
mkdir -p "$HOME"

# ── Launch SwarmUI ──
# --launch_mode none  = don't try to open a browser
# --host 0.0.0.0      = listen on all interfaces (required for RunPod proxy)
# --port 7801          = explicit port
echo "Starting SwarmUI..."
exec bash /SwarmUI/launch-linux.sh --launch_mode none --host 0.0.0.0 --port 7801
RUNPOD_ENTRY

RUN chmod +x /SwarmUI/launchtools/runpod-entrypoint.sh

EXPOSE 7801

ENTRYPOINT ["bash", "/SwarmUI/launchtools/runpod-entrypoint.sh"]
