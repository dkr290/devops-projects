FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# 1. Setup Environment
ENV DEBIAN_FRONTEND=noninteractive \
  PYTHONUNBUFFERED=1 \
  TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0" \
  FORCE_CUDA="1" \
  HF_HUB_ENABLE_HF_TRANSFER=1

WORKDIR /app

# 2. Install Dependencies
RUN apt-get update && apt-get install -y \
  python3.10 python3.10-dev python3-pip git wget ffmpeg libsm6 libxext6 ninja-build aria2 \
  && rm -rf /var/lib/apt/lists/*

# 3. Install PyTorch & Wan2GP
RUN pip3 install --upgrade pip setuptools wheel
# Use Torch 2.7+ for better Wan 2.2 support
RUN pip3 install torch torchvision torchaudio 
RUN git clone https://github.com/deepbeepmeep/Wan2GP.git . && \
  pip3 install -r requirements.txt

# 4. Install SVI Pro 2 & Acceleration Kernels
# SageAttention is vital for long videos (SVI Pro 2)
RUN pip3 install flash-attn --no-build-isolation
RUN git clone https://github.com/thu-ml/SageAttention.git /tmp/sage && \
  cd /tmp/sage && pip3 install . && rm -rf /tmp/sage

# Install Light2xv for FP4 support (Epic speed on RTX 5090)
RUN pip3 install light2xv


RUN ls -ltrh

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
