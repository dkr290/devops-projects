#!/bin/bash
docker run --rm -t \
  -e TORCH_CUDA_ARCH_LIST="8.6;8.9" \
  -v "$PWD:/work" -w /work \
  runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04 \
  bash -lc 'python3 -m pip wheel -w /work/wan2gp/runpod/wheels --no-build-isolation flash-attn==2.7.2.post1'

