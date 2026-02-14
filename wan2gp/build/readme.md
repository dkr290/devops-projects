RUN pip install --no-cache-dir "triton==3.4.0"

# Install multi-arch SageAttention wheel (built with SM 8.0, 8.6, 8.9, 9.0)

RUN wget https://huggingface.co/YOUR-USERNAME/sageattention-wheels/resolve/main/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
 pip install sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
 rm sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Copy and set up our startup and update scripts

# ...existing code...

# Make scripts executable

chmod +x wan2gp/runpod/build-sageattention-docker.sh
chmod +x wan2gp/runpod/upload-wheel.sh

# Build the wheel (requires nvidia-docker)

./wan2gp/runpod/build-sageattention-docker.sh ./wheels

# Upload to HuggingFace

./wan2gp/runpod/upload-wheel.sh ./wheels/sageattention-\*.whl your-username/sageattention-wheels
The wheel name will be something like `sageattention-2.2.0-cp311-cp311-linux_x86_64.whl`. Since it's built with multiple `TORCH_CUDA_ARCH_LIST` targets, it will work on A40, RTX 4090, A100, and H100.

# Compatibility matrix

COMPUTE CAPABILITY (SM) ARCHITECTURE NAME CONSUMER GPUS DATACENTER GPUS
SM 8.6 Ampere RTX 3090, RTX 3080 Ti A40, A6000
SM 8.9 Ada Lovelace RTX 4090, RTX 4080 L4, L40, L40S
SM 9.0 Hopper None H100, H800, H20
SM 10.0 Blackwell RTX 5090, RTX 5080 (new) B100, B200

# Build options

# For 4 CPU cores (most laptops)

export MAX_JOBS=2
export NVCC_APPEND_FLAGS="--threads 2 -O2"

# For 8 CPU cores (high-end desktop)

export MAX_JOBS=4
export NVCC_APPEND_FLAGS="--threads 4 -O2"

# For 16+ CPU cores (workstation/server)

export MAX_JOBS=8
export NVCC_APPEND_FLAGS="--threads 4 -O2"

# For 32+ CPU cores (heavy server)

export MAX_JOBS=16
export NVCC_APPEND_FLAGS="--threads 2 -O2"

# Build with these architectures:

# Most common RunPod GPUs

export TORCH_CUDA_ARCH_LIST="8.6;8.9" # RTX 3090, RTX 4090, L40

# If you want to support H100 too (requires separate build)

export TORCH_CUDA_ARCH_LIST="9.0" # H100 only

# For RTX 5090 (new!)

export TORCH_CUDA_ARCH_LIST="10.0" # RTX 5090

Recommended Build Strategy:

# Build 1: For most RunPod GPUs (3090, 4090, L40)

TORCH_CUDA_ARCH_LIST="8.6;8.9"

# Build 2: For H100 (if needed)

TORCH_CUDA_ARCH_LIST="9.0"

# Build 3: For RTX 5090 (if available)

TORCH_CUDA_ARCH_LIST="10.0"
