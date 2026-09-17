wan2gp
pipx install uv

# or if you don't have pipx:

pip install uv
or curl -LsSf https://astral.sh/uv/install.sh | sh

cd ~/my-wan2gp-project
or
cd wan2gp-data/
cd workspace/
uv venv --python 3.11

source .venv/bin/activate
uv pip install torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 --extra-index-url https://download.pytorch.org/whl/cu130
git clone https://github.com/deepbeepmeep/Wan2GP.git
uv pip install -r requirements.txt

cd ../workspace
uv pip install "setuptools<=75.8.2" --force-reinstall
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention
uv pip install --no-build-isolation -e .
cd Wan2GP
uv run python -c "import sageattention; print('SageAttention OK')"

## build the sparge attention with the following buid script

```bash 

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

        echo ">>> Creating python symlink (required by SpargeAttn setup.py internals)"
        ln -sf /usr/local/bin/python3.11 /usr/local/bin/python

        echo ">>> Installing PyTorch 2.10 cu130"
        python3.11 -m pip install torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 \
            --index-url https://download.pytorch.org/whl/cu130

        echo ">>> Installing build deps"
        python3.11 -m pip install setuptools wheel ninja packaging

        echo ">>> Cloning SpargeAttention"
        git clone https://github.com/woct0rdho/SpargeAttn.git /tmp/SpargeAttn
        cd /tmp/SpargeAttn
        git submodule update --init --recursive


        echo ">>> Patching setup.py"
        sed -i "s/\"-Xcompiler\", \"-include,cassert\", //g" setup.py

        echo ">>> Setting arch for RTX 3090 (SM 8.6)"
        export TORCH_CUDA_ARCH_LIST="8.0;8.6"

        echo ">>> Fixing NVCC for CUDA 13.x"
        export NVCC_PREPEND_FLAGS="-include assert.h"

        echo ">>> Building wheel"
        python3.11 -m pip wheel -v --no-deps --no-build-isolation . -w /output

        echo ">>> Verifying instantiation files were generated"
        find csrc/qattn/instantiations_sm80 -name "*.cu" | wc -l

        echo ">>> Done. Wheels saved in /output"
    '

ls -lh "$OUTPUT_DIR"/*.whl
```

#intall it
uv pip install wheels/spas_sage_attn-0.1.0-cp311-cp311-linux_x86_64.whl
cd Wan2GP
uv run python -c "import spas_sage_attn; print('SpargeAttention OK')"

##gguf install
uv pip install --no-deps https://github.com/deepbeepmeep/kernels/releases/download/gguf-v1.0.21/llamacpp_gguf_cuda-1.0.21%2Btorch210cu130py311-cp311-cp311-linux_x86_64.whl

nunchako
uv pip install https://github.com/nunchaku-ai/nunchaku/releases/download/v1.2.1/nunchaku-1.2.1+cu13.0torch2.10-cp311-cp311-linux_x86_64.whl

uv run python wgp.py --server-name 0.0.0.0 --server-port 7860
