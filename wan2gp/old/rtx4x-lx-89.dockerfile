FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

# 1. Setup Environment
ENV DEBIAN_FRONTEND=noninteractive \
  PYTHONUNBUFFERED=1 \
  TORCH_CUDA_ARCH_LIST="8.9" \
  FORCE_CUDA="1" \
  HF_HUB_ENABLE_HF_TRANSFER=1

WORKDIR /app

# 2. Install Dependencies
RUN apt-get update && apt-get install -y \
  python3.10 python3.10-dev python3-pip git wget ffmpeg libsm6 libxext6 ninja-build aria2 \
  && rm -rf /var/lib/apt/lists/*

# Use Torch 2.7+ for better Wan 2.2 support

RUN pip3 install --upgrade pip setuptools wheel && \
  pip3 install torch==2.7.1 torchvision==0.22.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cu128 && \
  pip3 install -U "triton<3.4" && \
  python3 -m pip install "setuptools<=75.8.2" --force-reinstall && \
  git clone https://github.com/thu-ml/SageAttention /tmp/sage && \
  cd /tmp/sage && pip3 install -e . --no-build-isolation && \
  cd /app && rm -rf /tmp/sage

RUN git clone https://github.com/deepbeepmeep/Wan2GP.git . && \
  pip3 install -r requirements.txt



RUN pip3 install flash-attn==2.7.2.post1 --no-build-isolation




# 5. Startup Script
COPY run.sh .
RUN chmod +x run.sh

EXPOSE 7860

# Health check for RunPod
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s \
  CMD curl -f http://localhost:7860/ || exit 1

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

CMD ["./run.sh"]
