#!/bin/bash
set -e

echo "=== Building SageAttention for Multiple Architectures ==="

# Requires: CUDA toolkit, PyTorch installed locally
# Run this on a machine with CUDA development tools

BUILD_DIR="/tmp/sageattention-build"
OUTPUT_DIR="${1:-./wheels}"

mkdir -p "$OUTPUT_DIR"
rm -rf "$BUILD_DIR"

git clone https://github.com/thu-ml/SageAttention "$BUILD_DIR"
cd "$BUILD_DIR"
git checkout v2.2.0

# Build for multiple architectures:
# 8.0 = A100
# 8.6 = A40, RTX 3090
# 8.9 = RTX 4090 (Ada)
# 9.0 = H100
export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0"

echo "Building wheel with TORCH_CUDA_ARCH_LIST=$TORCH_CUDA_ARCH_LIST"

pip wheel --no-build-isolation --no-deps -w "$OUTPUT_DIR" .

echo ""
echo "=== Build Complete ==="
ls -la "$OUTPUT_DIR"/*.whl
echo ""
echo "Upload the wheel to your storage and update your Dockerfile"

# Cleanup
rm -rf "$BUILD_DIR"

