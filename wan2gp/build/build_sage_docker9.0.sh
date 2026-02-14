#!/bin/bash

OUTPUT_DIR="${1:-$(pwd)/wheels}"
mkdir -p "$OUTPUT_DIR"

echo "=== Building SageAttention (Excluding SM90-only code) ==="

docker run --rm --gpus all \
    -v "$OUTPUT_DIR:/output" \
    runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04 \
    bash -c '
        set -e
        pip install --no-cache-dir "triton>=3.3.0,<3.4.0" "setuptools<75.8.2" "wheel" "ninja"

        git clone https://github.com/thu-ml/SageAttention /tmp/sage
        cd /tmp/sage
        git checkout v2.2.0

        # OPTION 1: Build only 8.9 (Ada) - most compatible with RunPod
        # export TORCH_CUDA_ARCH_LIST="8.9"

        # OR OPTION 2: Build 8.6+8.9 (Ampere + Ada) - no SM90
        # export TORCH_CUDA_ARCH_LIST="8.6;8.9"

        # OR OPTION 3: Build ONLY 9.0 (Hopper only)
        export TORCH_CUDA_ARCH_LIST="9.0"

        export MAX_JOBS=2
        export NVCC_APPEND_FLAGS="--threads 2 -O2"

        rm -rf build/ dist/ *.egg-info

        echo "Building for architecture(s): $TORCH_CUDA_ARCH_LIST"
        python setup.py bdist_wheel 2>&1 | tee /output/build.log

        if [ -d dist ]; then
            cp dist/*.whl /output/
            echo "✓ Build successful!"
            ls -lh /output/*.whl
        else
            echo "✗ Build failed"
            exit 1
        fi
    '

ls -lh "$OUTPUT_DIR"/*.whl
