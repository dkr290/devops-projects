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
        pip install --no-cache-dir "triton==3.2.0" "setuptools<75.8.2" "wheel" 
        echo "Cloning SageAttention..."
        git clone https://github.com/thu-ml/SageAttention /tmp/sage
        cd /tmp/sage
        git checkout v2.2.0
        
        echo "Building wheel for multiple architectures..."
        export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0+PTX"
        # THE FIX: Force the compiler to respect the hardware register limit
        # This prevents the "Exit Code 255" crash during ptxas optimization
        export NVCC_APPEND_FLAGS="-maxrregcount=255"
        export MAX_JOBS=8
        pip wheel --no-build-isolation --no-deps -w /output .
        
        echo "Build complete!"
        ls -la /output/*.whl
    '

echo ""
echo "=== Wheel built successfully ==="
ls -la "$OUTPUT_DIR"/*.whl

