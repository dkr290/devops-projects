RUN pip install --no-cache-dir "triton==3.4.0"

# Install multi-arch SageAttention wheel (built with SM 8.0, 8.6, 8.9, 9.0)

RUN wget https://huggingface.co/YOUR-USERNAME/sageattention-wheels/resolve/main/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
 pip install sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
 rm sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Copy and set up our startup and update scripts

# ...existing code...

# Make scripts executable

chmod +x wan2gp/runpod/build-sageattention-docker.sh
chmod +x wan2gp/runpod/upload-wheel.sh

# Build the wheel (requires nvidia-docker)

./wan2gp/runpod/build-sageattention-docker.sh ./wheels

# Upload to HuggingFace

./wan2gp/runpod/upload-wheel.sh ./wheels/sageattention-\*.whl your-username/sageattention-wheels
The wheel name will be something like `sageattention-2.2.0-cp311-cp311-linux_x86_64.whl`. Since it's built with multiple `TORCH_CUDA_ARCH_LIST` targets, it will work on A40, RTX 4090, A100, and H100.
