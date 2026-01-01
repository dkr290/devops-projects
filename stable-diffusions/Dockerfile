FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  wget \
  python3 \
  python3-venv \
  python3-pip \
  libgl1 \
  libglib2.0-0 \
  && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Clone AUTOMATIC1111
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

WORKDIR /workspace/stable-diffusion-webui

# Install Python dependencies
RUN python3 -m venv venv
RUN ./venv/bin/pip install --upgrade pip wheel setuptools

# Install requirements (Torch will be installed at runtime unless pinned)
RUN ./venv/bin/pip install -r requirements.txt || true

# Optional: install xformers (recommended)
RUN ./venv/bin/pip install xformers --extra-index-url https://download.pytorch.org/whl/cu121

# Expose WebUI port
EXPOSE 7860

# Run WebUI with sane defaults for RunPod
CMD ["bash", "-c", "./venv/bin/python3 webui.py --listen --port 7860 --xformers --enable-insecure-extension-access --api"]

