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
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
  pip3 install --upgrade pip setuptools wheel

RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
  pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

RUN git clone https://github.com/deepbeepmeep/Wan2GP.git . && \
  pip3 install -r requirements.txt

# 4. Install SVI Pro 2 & Acceleration Kernels
# This layer will be cached after first build
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
  --mount=type=cache,target=/tmp,sharing=locked \
  pip3 install flash-attn --no-build-isolation


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
