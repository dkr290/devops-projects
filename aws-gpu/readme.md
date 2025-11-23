# For Wan 1.3B

```
sudo apt install python3-venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip wheel setuptools
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install flash-attn --no-build-isolation

```

# Follow the instrictions here

https://huggingface.co/Wan-AI/Wan2.1-VACE-1.3B

```
git clone https://github.com/Wan-Video/Wan2.1.git
cd Wan2.1
pip install -r requirements.txt
pip install "huggingface_hub[cli]"
huggingface-cli download Wan-AI/Wan2.1-T2V-14B --local-dir ./Wan2.1-T2V-14B
python generate.py  --task t2v-1.3B --size 832*480 --ckpt_dir ./Wan2.1-T2V-1.3B --offload_model True --t5_cpu --sample_shift 8 --sample_guide_scale 6 --prompt "Two anthropomorphic cats in comfy boxing gear and bright gloves fight intensely on a spotlighted stage."

```
