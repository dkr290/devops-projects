#!/bin/bash

OUTPUT_DIR="${1:-$(pwd)/wheels}"
mkdir -p "$OUTPUT_DIR"

echo "=== Building SageAttention for Multiple Architectures ==="

docker run --rm --gpus all \
    --memory="16g" \
    --memory-swap="24g" \
    --shm-size="8g" \
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

        echo "Building wheel for architectures: 8.6, 8.9, 9.0"

        # Your specified architectures only
        export TORCH_CUDA_ARCH_LIST="8.6;8.9;9.0"

        # KEY FIX: Compile sequentially to avoid OOM
        export MAX_JOBS=1
        export EXT_PARALLEL=1

        # Reduce memory usage per compilation unit
        export NVCC_APPEND_FLAGS="--threads 1 -O2"

        # Increase stack size
        ulimit -s unlimited 2>/dev/null || true

        # Clear any cached builds
        rm -rf build/ dist/ *.egg-info

        echo "Starting compilation (this may take 20-30 minutes)..."
        echo "Compiling for: RTX 3090/A6000 (8.6), RTX 4090/L40 (8.9), H100 (9.0)"

        # Build with verbose output
        pip wheel --no-build-isolation --no-deps -w /output . -v 2>&1 | tee /output/build.log

        if ls /output/*.whl 1> /dev/null 2>&1; then
            echo "✓ Build complete!"
            ls -lh /output/*.whl
        else
            echo "✗ Build failed"
            tail -100 /output/build.log
            exit 1
        fi
    '

echo ""
if ls "$OUTPUT_DIR"/*.whl 1> /dev/null 2>&1; then
    echo "=== ✓ Universal wheel built successfully ==="
    ls -lh "$OUTPUT_DIR"/*.whl
    echo ""
    echo "Supported GPUs:"
    echo "  - SM 8.6: RTX 3090, A40, A6000"
    echo "  - SM 8.9: RTX 4090, L4, L40, L40S"
    echo "  - SM 9.0: H100, H800, H20"
else
    echo "=== ✗ Build failed ==="
    [ -f "$OUTPUT_DIR/build.log" ] && tail -100 "$OUTPUT_DIR/build.log"
    exit 1
fi
