#!/bin/bash

# Get the total number of CPU cores available
CPU_CORES=$(nproc)

echo "Starting build with $CPU_CORES CPU cores..."

nohup docker run --rm \
  -e TORCH_CUDA_ARCH_LIST="8.6;8.9" \
  -e MAX_JOBS=$CPU_CORES \
  -v "$PWD:/work" -w /work \
  runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04 \
  bash -lc "python3 -m pip wheel -w /work/wan2gp/runpod/wheels --no-build-isolation flash-attn==2.7.2.post1" \
  > build_log.txt 2>&1 &

echo "Build running in background. Check progress with: tail -f build_log.txt"
