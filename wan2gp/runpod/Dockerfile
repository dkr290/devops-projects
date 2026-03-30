# Use the official RunPod base image, which includes a pre-configured environment.
#FROM runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04
FROM runpod/pytorch:2.7.1-py3.10-cuda12.8.1-cudnn-devel-ubuntu22.04

# Set environment variables for non-interactive installs.
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies 
RUN rm -f /etc/apt/sources.list.d/cuda*.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  ffmpeg \
  tmux \
  build-essential \
  rsync \
  htop \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Clone the application source code to a "safe" location that won't be volume-mounted.
RUN git clone https://github.com/deepbeepmeep/Wan2GP.git /opt/wan2gp_source \
  && cd /opt/wan2gp_source \
  && git checkout main 


# RUN sed -i \
#   -e 's/^torch>=/#torch>=/' \
#   -e 's/^torchvision>=/#torchvision>=/' \
#   -e 's/^onnxruntime/#onnxruntime/' \
#   /opt/wan2gp_source/requirements.txt \
#   && python3 -m pip install --no-cache-dir   -r /opt/wan2gp_source/requirements.txt \
#   && rm -rf /root/.cache/pip

RUN sed -i \
  -e 's/^torch>=/#torch>=/' \
  -e 's/^onnxruntime/#onnxruntime/' \
  /opt/wan2gp_source/requirements.txt \
  && python3 -m pip install --no-cache-dir   -r /opt/wan2gp_source/requirements.txt \
  && rm -rf /root/.cache/pip


# Install CUDA 12.x compatible onnxruntime-gpu
# Option 1: Use the stable release (recommended, simpler)
RUN pip install --no-cache-dir onnxruntime-gpu==1.22.0 \
  --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/


# # Option 2: Use the nightly/dev build from the CUDA 12 nightly feed
# RUN pip install --no-cache-dir onnxruntime-gpu==1.25.0.dev20260210001 \
#     --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12-nightly/pypi/simple/



#RUN pip install --no-cache-dir "setuptools<75.0.0" wheel "triton==3.4.0"
RUN pip install --no-cache-dir "triton>=3.3.0,<3.4.0" "setuptools<75.8.2"
# 2. Build SageAttention 2.2.0 from source 
# This is much faster than the flash-attn build (approx 5 mins)
# RUN git clone https://github.com/thu-ml/SageAttention /opt/SageAttention && \
#   cd /opt/SageAttention && \
#   TORCH_CUDA_ARCH_LIST="8.6;8.9;9.0" \
#   python3 -m pip install --no-build-isolation -e .

# RUN wget https://huggingface.co/ModelsLab/Sage_2_plus_plus_build/resolve/main/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
#   pip install sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
#   rm sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

## Copy the pre-build one build for 8.6 and 8.9 archs only 
COPY wheels/arch8689/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl  /tmp/
RUN pip install --no-cache-dir /tmp/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
  && rm /tmp/sageattention-*.whl
## Install GGUF enhancer 
RUN pip install https://github.com/deepbeepmeep/kernels/releases/download/GGUF_Kernels/llamacpp_gguf_cuda-1.0.2+torch271cu128py310-cp310-cp310-linux_x86_64.whl



# Copy and set up our startup and update scripts
COPY start-wan2gp.sh /usr/local/bin/start-wan2gp.sh
COPY update-wan2gp.sh /usr/local/bin/update-wan2gp.sh
COPY restart-wan2gp.sh /usr/local/bin/restart-wan2gp.sh
RUN chmod +x /usr/local/bin/start-wan2gp.sh \
  && chmod +x /usr/local/bin/update-wan2gp.sh \
  && chmod +x /usr/local/bin/restart-wan2gp.sh

# Expose ports for authenticated Gradio interface and Jupyter Lab
EXPOSE 7860 8888

# Use our startup script as the main command
CMD ["/usr/local/bin/start-wan2gp.sh"] 
