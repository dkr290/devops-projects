FROM runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04

# ============================================================
# SwarmUI for RunPod — Pre-baked for fast startup
# ============================================================

ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:/usr/share/dotnet"

# ── Install .NET 8 SDK ──
RUN wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh && \
  chmod +x /tmp/dotnet-install.sh && \
  /tmp/dotnet-install.sh --channel 8.0 --install-dir /usr/share/dotnet && \
  rm /tmp/dotnet-install.sh && \
  dotnet --version

# ── Install system deps ──
RUN apt-get update && apt-get install -y \
  ffmpeg \
  htop \
  libglib2.0-0 \
  libgl1-mesa-glx \
  libgl1 \
  && rm -rf /var/lib/apt/lists/*

# ── Clone SwarmUI ──
RUN git clone https://github.com/mcmonkeyprojects/SwarmUI.git /SwarmUI

WORKDIR /SwarmUI

RUN git config --global --add safe.directory '*'

# ── Pre-build SwarmUI (dotnet compile) ──
RUN dotnet build src/SwarmUI.csproj --configuration Release

# ── Pre-install ComfyUI backend + PyTorch ──
# This is what launch-linux.sh normally does on first boot
RUN mkdir -p dlbackend && \
  cd dlbackend && \
  git clone https://github.com/comfyanonymous/ComfyUI.git && \
  cd ComfyUI && \
  python3.11 -m venv venv && \
  ./venv/bin/python -s -m pip install --upgrade pip setuptools && \
  ./venv/bin/python -s -m pip install \
  torch \
  torchvision \
  torchaudio \
  --index-url https://download.pytorch.org/whl/cu129 && \
  ./venv/bin/python -s -m pip install \
  -r requirements.txt

# ── Set fake home so pip/cache works correctly ──
RUN mkdir -p /SwarmUI/dlbackend/linuxhome

# ============================================================
# RunPod entrypoint
# ============================================================
RUN cat <<'RUNPOD_ENTRY' > /SwarmUI/launchtools/runpod-entrypoint.sh
#!/usr/bin/env bash
set -e

cd /SwarmUI

WORKSPACE="/workspace"

mkdir -p "$WORKSPACE/SwarmUI/Models"
mkdir -p "$WORKSPACE/SwarmUI/Output"
mkdir -p "$WORKSPACE/SwarmUI/Data"
mkdir -p "$WORKSPACE/SwarmUI/dlbackend"
mkdir -p "$WORKSPACE/SwarmUI/DLNodes"
mkdir -p "$WORKSPACE/SwarmUI/Extensions"
mkdir -p "$WORKSPACE/SwarmUI/CustomWorkflows"

link_dir() {
    local CONTAINER_PATH="$1"
    local WORKSPACE_PATH="$2"

    if [ -L "$CONTAINER_PATH" ]; then
        return
    fi

    if [ -d "$CONTAINER_PATH" ] && [ -z "$(ls -A "$WORKSPACE_PATH" 2>/dev/null)" ]; then
        echo "Seeding $WORKSPACE_PATH from $CONTAINER_PATH"
        cp -a "$CONTAINER_PATH/." "$WORKSPACE_PATH/"
    fi

    rm -rf "$CONTAINER_PATH"
    ln -sf "$WORKSPACE_PATH" "$CONTAINER_PATH"
    echo "Linked $CONTAINER_PATH -> $WORKSPACE_PATH"
}

link_dir "/SwarmUI/Models"   "$WORKSPACE/SwarmUI/Models"
link_dir "/SwarmUI/Output"   "$WORKSPACE/SwarmUI/Output"
link_dir "/SwarmUI/Data"     "$WORKSPACE/SwarmUI/Data"
link_dir "/SwarmUI/dlbackend" "$WORKSPACE/SwarmUI/dlbackend"
link_dir "/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/DLNodes" "$WORKSPACE/SwarmUI/DLNodes"
link_dir "/SwarmUI/src/Extensions" "$WORKSPACE/SwarmUI/Extensions"
link_dir "/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/CustomWorkflows" "$WORKSPACE/SwarmUI/CustomWorkflows"

export HOME=/SwarmUI/dlbackend/linuxhome
mkdir -p "$HOME"

echo "=== GPU Check ==="
nvidia-smi || echo "WARNING: nvidia-smi failed"
echo "=================="

echo "Starting SwarmUI..."
exec bash /SwarmUI/launch-linux.sh --launch_mode none --host 0.0.0.0 --port 7801
RUNPOD_ENTRY

RUN chmod +x /SwarmUI/launchtools/runpod-entrypoint.sh

EXPOSE 7801

ENTRYPOINT ["bash", "/SwarmUI/launchtools/runpod-entrypoint.sh"]
