## step 1
cd ~/ComfyUI
source venv/bin/activate


# step 2
If nvcc --version prints CUDA 13.0 / 13.x: Skip directly to Step 3.
If nvcc is not found: Install the CUDA 13.0 toolkit directly inside your venv via pip (no root/sudo needed) and link libcudart.so:

```
pip install 'cuda-toolkit[nvcc,crt,cccl,nvvm,culibos]==13.0.3' setuptools wheel packaging ninja
export CUDA_HOME=$VIRTUAL_ENV/lib/python3.12/site-packages/nvidia/cu13
export PATH=$CUDA_HOME/bin:$PATH
ln -sf libcudart.so.13 $CUDA_HOME/lib/libcudart.so
```

Step 3: Clone & Compile SageAttention 2.2.0 for Your RTX 3090
Make sure build tools are present, clone the official repository, and compile specifically for Compute Capability 8.6 (RTX 3090) with the required C++20 and cassert flags for PyTorch 2.14.1 + CUDA 13:

```
pip install setuptools wheel packaging ninja
cd ~
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention

TORCH_CUDA_ARCH_LIST="8.6" \
EXT_PARALLEL=1 \
MAX_JOBS=4 \
CXX_APPEND_FLAGS="-std=c++20 -include cassert" \
NVCC_APPEND_FLAGS="-std=c++20 -include cassert --threads 2" \
pip install --no-build-isolation --no-deps .
```


# step 4 verify 

```
cd ~
python -c "import torch; from sageattention import sageattn; q = torch.randn(1, 8, 1024, 64, dtype=torch.float16, device='cuda'); out = sageattn(q, q, q); print('SageAttention OK:', out.shape)"
```
