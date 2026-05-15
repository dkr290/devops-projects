# Use the official RunPod base image, which includes a pre-configured environment.
FROM nvidia/cuda:13.1.1-cudnn-devel-ubuntu24.04

# Set environment variables for non-interactive installs.
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies + Python
RUN rm -f /etc/apt/sources.list.d/cuda*.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends software-properties-common && \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  python3.11 \
  python3.11-dev \ 
  python3.11-venv \
  python3-pip \
  git \
  ffmpeg \
  tmux \
  build-essential \
  rsync \
  htop \
  wget \
  curl \
  nvitop \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Make python3.11 the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 -- --break-system-packages \
  && python3.11 -m pip install --break-system-packages --upgrade setuptools wheel


# Install PyTorch 2.10.0 for CUDA 13.x
RUN pip install --no-cache-dir \
  torch==2.10.0 \
  torchvision==0.25.0 \
  torchaudio==2.10.0 \
  --index-url https://download.pytorch.org/whl/cu130

# Clone the application source code to a "safe" location that won't be volume-mounted.
RUN git clone https://github.com/deepbeepmeep/Wan2GP.git /opt/wan2gp_source \
  && cd /opt/wan2gp_source \
  && git checkout main 


RUN pip install --upgrade pip setuptools wheel

RUN python -m pip install --no-cache-dir  -r /opt/wan2gp_source/requirements.txt \
  && rm -rf /root/.cache/pip


## Copy the pre-build one build for 8.6 
COPY wheels/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl  /tmp/
RUN pip install --no-cache-dir /tmp/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
  && rm /tmp/sageattention-*.whl
## Install GGUF enhancer does not work with this image needs to be build  
# RUN pip install https://github.com/deepbeepmeep/kernels/releases/download/GGUF_Kernels/llamacpp_gguf_cuda-1.0.2+torch271cu128py310-cp310-cp310-linux_x86_64.whl
RUN pip install https://github.com/deepbeepmeep/kernels/releases/download/GGUF_Kernels/llamacpp_gguf_cuda-1.0.2+torch210cu13py311-cp311-cp311-linux_x86_64.whl
RUN pip install https://github.com/nunchaku-ai/nunchaku/releases/download/v1.2.1/nunchaku-1.2.1+cu13.0torch2.10-cp311-cp311-linux_x86_64.whl

# Copy and set up our startup and update scripts
COPY start-wan2gp.sh /usr/local/bin/start-wan2gp.sh
COPY update-wan2gp.sh /usr/local/bin/update-wan2gp.sh
COPY restart-wan2gp.sh /usr/local/bin/restart-wan2gp.sh
COPY gpu_dashboard.py /usr/local/bin/gpu_dashboard.py
RUN chmod +x /usr/local/bin/start-wan2gp.sh \
  && chmod +x /usr/local/bin/update-wan2gp.sh \
  && chmod +x /usr/local/bin/restart-wan2gp.sh

# Expose ports for authenticated Gradio interface and Jupyter Lab
EXPOSE 7860

# Use our startup script as the main command
CMD ["/usr/local/bin/start-wan2gp.sh"] 
