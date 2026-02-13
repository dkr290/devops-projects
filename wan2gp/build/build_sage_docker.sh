#!/bin/bash
set -e

# Build SageAttention wheel inside Docker for consistency
# This matches your RunPod base image

OUTPUT_DIR="${1:-$(pwd)/wheels}"
mkdir -p "$OUTPUT_DIR"

echo "=== Building SageAttention in Docker ==="

docker run --rm --gpus all \
    -v "$OUTPUT_DIR:/output" \
    runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04 \
    bash -c '
        set -e
        echo "Installing build dependencies..."
        pip install --no-cache-dir "triton>=3.3.0,<3.4.0" "setuptools<75.8.2" "wheel" "ninja"    

        echo "Cloning SageAttention..."
        git clone https://github.com/thu-ml/SageAttention /tmp/sage
        cd /tmp/sage
        git checkout v2.2.0
        
        echo "Building wheel for multiple architectures..."
        export TORCH_CUDA_ARCH_LIST="8.6;8.9;9.0"

         # 1. Limit registers per thread
        export NVCC_APPEND_FLAGS="--threads 4 -Xptxas=-v"
        
        # 2. Reduce optimization level temporarily for problematic kernels
        # export NVCC_APPEND_FLAGS="$NVCC_APPEND_FLAGS -O1"
        
        # 3. Split compilation to reduce memory pressure
        export MAX_JOBS=2  # Reduce parallel compilation jobs
        
        # 4. Alternative: Use separate compilation mode
        #export NVCC_APPEND_FLAGS="$NVCC_APPEND_FLAGS -dc"
        
           

        pip wheel --no-build-isolation --no-deps -w /output .
        
        echo "Build complete!"
        ls -la /output/*.whl
    '

echo ""
echo "=== Wheel built successfully ==="
ls -la "$OUTPUT_DIR"/*.whl

