# Character LoRA Training on RTX 3090 (24 GB) — No ai-toolkit

Local LoRA training for **character consistency** using:
**SDXL**, **FLUX.1-dev**, **FLUX.2 klein 9B**, **Qwen-Image**.

> ⚠️ These tools move fast. Commands/flags below are correct to the best of my
> knowledge but **always check each repo's README/docs** for the current version,
> especially for FLUX.2 klein (newest model).

---

## TL;DR — Recommendations

| Rank | Model | Best trainer on a 3090 | Why |
|---|---|---|---|
| 🥇 | **FLUX.2 klein base 9B** | musubi-tuner / OneTrainer / SimpleTuner | Modern, fast, fits 24 GB in bf16, great likeness |
| 🥈 | **FLUX.1-dev** | OneTrainer / kohya_ss | Proven, huge amount of guides, fits 24 GB easily |
| 🥉 | **Qwen-Image** (20B) | musubi-tuner / OneTrainer / SimpleTuner | Best prompt following, slower (fp8 + offload) |
| ➕ | **SDXL / Illustrious / Pony** | OneTrainer / kohya_ss | Fastest, best for anime/stylized |

### Which tool?
- **OneTrainer** — ⭐ the all-rounder. GUI **and** CLI, supports **all four** of your models
  (SDXL, FLUX.1, FLUX.2 dev/klein, Qwen-Image, Z-Image, Chroma…). → [guides/OneTrainer.md](guides/OneTrainer.md)
- **musubi-tuner** — CLI only, very memory-efficient, FLUX.2 klein + Qwen-Image + Z-Image (no SDXL / FLUX.1-dev). → section 5 below
- **kohya_ss** — classic GUI for SDXL + FLUX.1-dev (no klein / Qwen). → [guides/kohya_ss.md](guides/kohya_ss.md)
- **SimpleTuner** — web UI + JSON config, supports the most models (all four), more advanced. → [guides/SimpleTuner.md](guides/SimpleTuner.md)
- Other options (not covered in depth):
  - **FluxGym** — simplest web UI, FLUX.1-dev only (built on kohya): https://github.com/cocktailpeanut/fluxgym
  - **diffusion-pipe** — CLI/DeepSpeed, Qwen-Image/Flux/Wan etc.: https://github.com/tdrussell/diffusion-pipe

### Trainer × Model support matrix (checked Nov 2026)

| Trainer | Interface | SDXL | FLUX.1-dev | FLUX.2 klein | Qwen-Image | Difficulty |
|---|---|---|---|---|---|---|
| **OneTrainer** | GUI + CLI | ✅ | ✅ | ✅ | ✅ | Easy |
| **musubi-tuner** | CLI | ❌ | ❌ (Kontext only) | ✅ | ✅ | Medium |
| **kohya_ss** | GUI (+ sd-scripts CLI) | ✅ | ✅ | ❌ | ❌ | Medium |
| **SimpleTuner** | Web UI + JSON/CLI | ✅ | ✅ | ✅ | ✅ | Medium-Hard |
| FluxGym | Web UI | ❌ | ✅ | ❌ | ❌ | Easiest |
| diffusion-pipe | CLI | ✅ | ✅ | check | ✅ | Medium-Hard |

**Suggested path:** OneTrainer (GUI) for everything → musubi-tuner when you want lean CLI runs for klein/Qwen.

---

## 0. Prerequisites

- NVIDIA driver + CUDA 12.x, Python 3.10–3.12, `git`
- **64 GB system RAM recommended** (32 GB minimum) — needed for offloading on Qwen/FLUX
- ~100 GB free disk for models
- Hugging Face account + `huggingface-cli login` (FLUX.1-dev / FLUX.2 are gated — accept license on HF first)

```bash
sudo apt install git python3-venv python3-pip
pip install -U "huggingface_hub[cli]"
huggingface-cli login
```

---

## 1. Dataset (most important part — same for every model)

### Images
- **15–40 images** of the character, ideally ~1024px, sharp, no watermarks, no other people
- **Vary everything except the character**: angles (front / 3/4 / profile), framing
  (close-up / half / full body), lighting, backgrounds, outfits, expressions
- If every image has the same outfit/background, the LoRA will bake it in

### Captions
One `.txt` per image with the same name:
```
dataset/
  001.png  001.txt
  002.jpg  002.txt
  ...
```
- Choose a unique **trigger word**: e.g. `zk3char`
- Caption what **changes** (clothes, pose, background, lighting), not fixed identity traits
- **FLUX / Qwen / klein** → natural language:
  `zk3char, a woman sitting in a cafe, wearing a red jacket, soft window light, side view`
- **SDXL (realistic)** → short natural language works
- **Illustrious / Pony (anime)** → booru tags:
  `zk3char, 1girl, sitting, cafe, red jacket, side view, window light`

Auto-captioning tools: **JoyCaption**, **Florence-2**, **WD14 tagger** (anime). OneTrainer & kohya_ss have built-in captioners. Always review by hand.

---

## 1b. Folder layout & file naming (this repo)

```
/home/dans/train/
├── README.md
├── guides/                       # OneTrainer.md, kohya_ss.md, SimpleTuner.md
├── models/                       # downloaded base models (big files)
│   ├── flux2/                    # flux2-klein-base-9b.safetensors, ae.safetensors, qwen3_8b/...
│   ├── qwen/                     # qwen_image_bf16.safetensors, qwen_image_vae..., qwen_2.5_vl_7b...
│   ├── flux1/                    # flux1-dev, ae, clip_l, t5xxl
│   └── sdxl/                     # sdxl base / illustrious / pony .safetensors
├── datasets/
│   └── zk3char/                  # one folder per character (= trigger word)
│       ├── images/               # ← YOUR PICTURES + CAPTIONS GO HERE
│       │   ├── 001_closeup_front.png
│       │   ├── 001_closeup_front.txt
│       │   ├── 002_halfbody_cafe.jpg
│       │   ├── 002_halfbody_cafe.txt
│       │   ├── 003_fullbody_street.webp
│       │   └── 003_fullbody_street.txt
│       ├── cache_flux2/          # auto-filled by musubi caching (FLUX.2)
│       └── cache_qwen/           # auto-filled by musubi caching (Qwen) — separate per model!
├── kohya/zk3char/img/10_zk3char woman/   # only for kohya_ss GUI (SDXL) — copy images+txt here
├── configs/
│   ├── dataset_flux2.toml        # musubi, FLUX.2 klein
│   ├── dataset_qwen.toml         # musubi, Qwen-Image
│   └── dataset_kohya_flux1.toml  # kohya sd-scripts, FLUX.1 / SDXL
└── output/                       # trained LoRAs (.safetensors)
```

### Naming rules
- **Image and caption must have the exact same name**, only the extension differs:
  `005_profile_beach.png` ↔ `005_profile_beach.txt`
- Formats: `.png`, `.jpg`, `.jpeg`, `.webp`
- Use a number prefix + short description: `NNN_<framing>_<scene>` — the name itself
  doesn't affect training, it just helps you see coverage at a glance.
  Framing words: `closeup`, `portrait`, `halfbody`, `fullbody`, `profile`, `back`
- No spaces or special characters in file names (use `_`)
- Don't put other files (or subfolders) inside `images/`
- Use a **separate cache folder per model** — latents from FLUX.2 and Qwen are not compatible
- kohya_ss GUI only: the folder name `10_zk3char woman` means *10 repeats*, trigger `zk3char`, class `woman`

### Good coverage checklist (example for 25 images)
| Type | Count |
|---|---|
| Close-up face (front, 3/4, profile) | 8 |
| Half body | 8 |
| Full body | 6 |
| Different expressions | spread across above |
| Different outfits / backgrounds / lighting | as many as possible |

### Caption examples (already in `datasets/zk3char/images/`)
```
001_closeup_front.txt:
zk3char, close-up portrait of a woman looking at the camera, neutral expression, plain grey studio background, soft front lighting

002_halfbody_cafe.txt:
zk3char, a woman sitting at a table in a cafe, wearing a red jacket, holding a coffee cup, smiling, warm window light, three-quarter view
```
Always start with the trigger word. Describe clothes/pose/scene/light; don't describe face, eye color or hair if they never change.

### Bulk rename helper
```bash
cd datasets/zk3char/images
i=1; for f in *.{png,jpg,jpeg,webp}; do [ -e "$f" ] || continue
  ext="${f##*.}"; mv -n "$f" "$(printf '%03d' $i)_img.$ext"; i=$((i+1)); done
# create empty caption files for any image missing one
for f in *.{png,jpg,jpeg,webp}; do [ -e "$f" ] || continue
  t="${f%.*}.txt"; [ -e "$t" ] || echo "zk3char, " > "$t"; done
```

### Using the configs
```bash
# FLUX.2 klein (musubi)
--dataset_config /home/dans/train/configs/dataset_flux2.toml
# Qwen-Image (musubi)
--dataset_config /home/dans/train/configs/dataset_qwen.toml
# FLUX.1 / SDXL (kohya sd-scripts)
--dataset_config /home/dans/train/configs/dataset_kohya_flux1.toml
--output_dir /home/dans/train/output
```

---

## 2–4. GUI tools — see separate guides

- **OneTrainer** → [guides/OneTrainer.md](guides/OneTrainer.md)
- **kohya_ss** (and sd-scripts CLI) → [guides/kohya_ss.md](guides/kohya_ss.md)
- **SimpleTuner** → [guides/SimpleTuner.md](guides/SimpleTuner.md)
- **FluxGym** (option, FLUX.1 only) → https://github.com/cocktailpeanut/fluxgym — `git clone`, follow README, or 1-click via Pinokio

---

## 5. Option D — musubi-tuner (CLI) ⭐ Recommended for Qwen-Image

Good for: **Qwen-Image / Qwen-Image-Edit** (and FLUX.2 klein if your version supports it — see `docs/`).
Very memory efficient (fp8 + block swap).

### Install
```bash
git clone https://github.com/kohya-ss/musubi-tuner
cd musubi-tuner
python3 -m venv venv && source venv/bin/activate
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
pip install -e .
accelerate config   # single GPU, no distributed, bf16
```

### Models needed (Qwen-Image) — see `docs/qwen_image.md` for exact links
- DiT: `qwen_image_bf16.safetensors`
- VAE: `qwen_image_vae.safetensors` (diffusion_pytorch_model)
- Text encoder: `qwen_2.5_vl_7b.safetensors`

### `dataset.toml`
```toml
[general]
resolution = [1024, 1024]
caption_extension = ".txt"
batch_size = 1
enable_bucket = true
bucket_no_upscale = false

[[datasets]]
image_directory = "/path/to/dataset"
cache_directory = "/path/to/dataset/cache"
num_repeats = 1
```

### Cache → Train
```bash
python src/musubi_tuner/qwen_image_cache_latents.py \
  --dataset_config dataset.toml --vae /models/qwen_image_vae.safetensors

python src/musubi_tuner/qwen_image_cache_text_encoder_outputs.py \
  --dataset_config dataset.toml --text_encoder /models/qwen_2.5_vl_7b.safetensors \
  --batch_size 1 --fp8_vl

accelerate launch --num_cpu_threads_per_process 1 --mixed_precision bf16 \
  src/musubi_tuner/qwen_image_train_network.py \
  --dit /models/qwen_image_bf16.safetensors \
  --vae /models/qwen_image_vae.safetensors \
  --text_encoder /models/qwen_2.5_vl_7b.safetensors \
  --dataset_config dataset.toml \
  --sdpa --mixed_precision bf16 \
  --fp8_base --fp8_scaled --blocks_to_swap 16 \
  --timestep_sampling shift --weighting_scheme none --discrete_flow_shift 2.2 \
  --optimizer_type adamw8bit --learning_rate 1e-4 \
  --gradient_checkpointing --max_data_loader_n_workers 2 --persistent_data_loader_workers \
  --network_module networks.lora_qwen_image --network_dim 16 \
  --max_train_epochs 16 --save_every_n_epochs 2 --seed 42 \
  --output_dir output --output_name zk3char_qwen
```
- OOM? Increase `--blocks_to_swap` (up to ~45), lower resolution to 768.
- Slow? Decrease `--blocks_to_swap` as far as VRAM allows.

### FLUX.2 klein 9B (verified against musubi-tuner `docs/flux_2.md`)

**Train on the BASE model** (`klein-base-9b`), not the distilled `klein-9b` — the docs recommend base for training.
The LoRA can then be used on either.

Models to download:
- DiT: `flux2-klein-base-9b.safetensors` from `black-forest-labs/FLUX.2-klein-base-9B`
- AE: `ae.safetensors` from `black-forest-labs/FLUX.2-dev` (NOT the `vae/` subfolder)
- Text encoder (Qwen3 8B): all split files from `black-forest-labs/FLUX.2-klein-9B`, pass the first (`...00001-of-00004.safetensors`)

```bash
python src/musubi_tuner/flux_2_cache_latents.py \
  --dataset_config dataset.toml --vae /models/ae.safetensors \
  --model_version klein-base-9b --vae_dtype bfloat16

python src/musubi_tuner/flux_2_cache_text_encoder_outputs.py \
  --dataset_config dataset.toml --text_encoder /models/qwen3_8b/model-00001-of-00004.safetensors \
  --model_version klein-base-9b --batch_size 4 --fp8_text_encoder

accelerate launch --num_cpu_threads_per_process 1 --mixed_precision bf16 \
  src/musubi_tuner/flux_2_train_network.py \
  --model_version klein-base-9b \
  --dit /models/flux2-klein-base-9b.safetensors \
  --vae /models/ae.safetensors \
  --text_encoder /models/qwen3_8b/model-00001-of-00004.safetensors \
  --dataset_config dataset.toml \
  --sdpa --mixed_precision bf16 \
  --fp8_base --fp8_scaled --fp8_text_encoder \
  --timestep_sampling flux2_shift --weighting_scheme none \
  --optimizer_type adamw8bit --learning_rate 1e-4 --gradient_checkpointing \
  --max_data_loader_n_workers 2 --persistent_data_loader_workers \
  --network_module networks.lora_flux_2 --network_dim 16 \
  --max_train_epochs 16 --save_every_n_epochs 2 --seed 42 \
  --output_dir output --output_name zk3char_klein9b
```
- 9B fits 24 GB; try **without** `--fp8_base --fp8_scaled` first (bf16 = best quality). Add them if OOM, then `--blocks_to_swap 8` (max 16).
- Inference with distilled `klein-9b`: guidance 1.0, 4 steps. With `klein-base-9b`: guidance 4.0, 50 steps.

### Z-Image (bonus, also in musubi-tuner)
6B, fast, great realism. See `docs/zimage.md` — scripts `zimage_cache_latents.py`, `zimage_cache_text_encoder_outputs.py`, `zimage_train_network.py`.

---

## 6. Other options

- **diffusion-pipe**: https://github.com/tdrussell/diffusion-pipe — `deepspeed --num_gpus=1 train.py --deepspeed --config examples/<model>.toml`
- **SimpleTuner**: see [guides/SimpleTuner.md](guides/SimpleTuner.md)

---

## 7. Recommended hyperparameters (starting points)

| Setting | SDXL | FLUX.1-dev | FLUX.2 klein 9B | Qwen-Image |
|---|---|---|---|---|
| Rank / Alpha | 32 / 16 | 16 / 16 | 16 / 16 | 16 / 16 |
| LR (UNet/DiT) | 1e-4 | 1e-4 | 1e-4 | 1e-4 |
| Text encoder LR | 5e-5 or off | off | off | off |
| Optimizer | AdamW8bit (or Prodigy, lr=1) | AdamW8bit | AdamW8bit | AdamW8bit |
| Total steps | 1500–3000 | 1500–2500 | 1500–2500 | 1500–3000 |
| Resolution | 1024 | 512–1024 | 512–1024 | 768–1024 |
| Batch size | 1–2 | 1 | 1 | 1 |
| Precision | bf16 | bf16 + fp8 base | bf16 (fp8 if needed) | bf16 + fp8 base + block swap |
| Time on 3090 (approx) | 30–60 min | 1–2 h | ~1 h | 2–5 h |

**Steps formula:** `steps = images × repeats × epochs / batch_size`
e.g. 20 images × 10 repeats × 10 epochs = 2000 steps.

---

## 8. Picking the best checkpoint

- Save every ~250 steps / 2 epochs, generate test images with the same seed
- **Undertrained:** face doesn't match → train longer / higher LR
- **Overtrained:** same pose/background/outfit every time, ignores prompts, fried colors → use an earlier checkpoint
- Best one is often at **60–80 %** of the run

Test prompts:
```
zk3char, portrait, studio lighting
zk3char, full body, walking in a snowy forest, winter coat
zk3char, sitting in a cafe, laughing, cinematic
```

---

## 9. Using the LoRA

- **ComfyUI** (recommended for FLUX/klein/Qwen): `LoraLoaderModelOnly` node, strength 0.7–1.0
- **Forge / SwarmUI**: put `.safetensors` in `models/Lora`, use `<lora:zk3char:0.9>` + trigger word
- Extra consistency: face detailer (ADetailer / FaceDetailer), PuLID (FLUX), IP-Adapter (SDXL)
- No-training alternative: **Qwen-Image-Edit** with a reference image — also great to *generate* extra dataset images for your LoRA

---

## 10. 3090 troubleshooting

| Problem | Fix |
|---|---|
| CUDA OOM | Lower resolution (768/512), enable fp8 base, gradient checkpointing, more block swap, close browser |
| System RAM OOM | Add swap / more RAM, fewer dataloader workers, cache to disk |
| Very slow | Less block swap, cache latents & text encoder outputs, `--sdpa` |
| LoRA does nothing | Check trigger word in prompt, correct base model, strength ≥ 0.8 |
| Black/NaN images (SDXL) | `--no_half_vae`, use bf16 not fp16 |

Monitor GPU: `watch -n1 nvidia-smi`
