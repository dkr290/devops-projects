#!/bin/bash

OUTPUT_DIR="${1:-$(pwd)/wheels}"
mkdir -p "$OUTPUT_DIR"

docker run --rm --gpus all \
    -v "$OUTPUT_DIR:/output" \
    nvidia/cuda:13.1.1-cudnn-devel-ubuntu24.04 \
    bash -c '
        set -e

        echo ">>> Installing build tools"
        apt-get update && apt-get install -y \
            build-essential git wget curl libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev libffi-dev

        echo ">>> Downloading Python 3.11 source"
        cd /tmp
        wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz
        tar -xf Python-3.11.9.tgz
        cd Python-3.11.9

        echo ">>> Building Python 3.11"
        ./configure --enable-optimizations
        make -j$(nproc)
        make altinstall   # installs python3.11 safely

        echo ">>> Installing pip"
        curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

        echo ">>> Installing PyTorch 2.10 cu130"
        python3.11 -m pip install torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 \
            --index-url https://download.pytorch.org/whl/cu130

        echo ">>> Installing build deps"
        python3.11 -m pip install setuptools wheel ninja packaging

        echo ">>> Cloning SpargeAttention"
        git clone https://github.com/woct0rdho/SpargeAttn.git /tmp/SpargeAttn
        cd /tmp/SpargeAttn

        echo ">>> Patching setup.py"
        sed -i "s/\"-Xcompiler\", \"-include,cassert\", //g" setup.py

        echo ">>> Setting arch for RTX 3090 (SM 8.6)"
        export TORCH_CUDA_ARCH_LIST="8.6"

        echo ">>> Fixing NVCC for CUDA 13.x"
        export NVCC_PREPEND_FLAGS="-include assert.h"

        echo ">>> Building wheel"
        python3.11 -m pip wheel -v --no-deps --no-build-isolation . -w /output

        echo ">>> Done. Wheels saved in /output"
    '

ls -lh "$OUTPUT_DIR"/*.whl

