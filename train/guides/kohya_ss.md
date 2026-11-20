# kohya_ss — Character LoRA guide (RTX 3090)

- GUI: https://github.com/bmaltais/kohya_ss
- Underlying CLI scripts: https://github.com/kohya-ss/sd-scripts

**Supports (for your list):** ✅ SDXL (incl. Illustrious / Pony) · ✅ FLUX.1-dev · ❌ FLUX.2 klein · ❌ Qwen-Image
(for klein / Qwen use musubi-tuner — same author, see README section 5 — or OneTrainer).

---

## 1. Install (Linux)

```bash
sudo apt install -y python3-venv python3-tk git
cd /home/dans/train
git clone --recursive https://github.com/bmaltais/kohya_ss.git
cd kohya_ss
./setup.sh
```

Start the GUI:
```bash
./gui.sh --listen 127.0.0.1 --server_port 7860 --inbrowser
```
Open http://127.0.0.1:7860

---

## 2. Dataset folder (kohya style)

The GUI's "folder mode" uses the folder name to set **repeats + trigger + class**:

```
/home/dans/train/kohya/zk3char/
├── img/
│   └── 10_zk3char woman/        # 10 = repeats, "zk3char" = trigger, "woman" = class
│       ├── 001_closeup_front.png
│       ├── 001_closeup_front.txt
│       └── ...
├── log/
└── model/                       # output LoRAs
```

Copy your dataset in:
```bash
cp /home/dans/train/datasets/zk3char/images/* "/home/dans/train/kohya/zk3char/img/10_zk3char woman/"
mkdir -p /home/dans/train/kohya/zk3char/{log,model}
```

> Alternatively use a TOML dataset config (`--dataset_config`), then the folder name doesn't matter —
> see `/home/dans/train/configs/dataset_kohya_flux1.toml`.

**Repeats:** aim for ~150–250 image-views per epoch. 20 images × 10 repeats = 200 steps/epoch → 10 epochs = 2000 steps.

---

## 3. GUI walkthrough — SDXL

Tab **LoRA → Training**:

1. **Configuration:** "Save as" `/home/dans/train/configs/kohya_zk3char_sdxl.json` (reload later)
2. **Source model**
   - Pretrained model: `/home/dans/train/models/sdxl/<model>.safetensors` (SDXL base / Illustrious / Pony)
   - Tick **SDXL**
3. **Folders**
   - Image folder: `/home/dans/train/kohya/zk3char/img`
   - Output folder: `/home/dans/train/kohya/zk3char/model`
   - Logging folder: `/home/dans/train/kohya/zk3char/log`
   - Model output name: `zk3char_sdxl`
4. **Parameters → Basic**
   - LoRA type: Standard
   - Train batch size: 1 (2 if fits)
   - Epochs: 10 · Save every N epochs: 2
   - Caption extension: `.txt`
   - Mixed precision: `bf16` · Save precision: `bf16`
   - Cache latents: ✅ · Cache latents to disk: ✅
   - LR scheduler: `cosine` (or `constant`) · Optimizer: `AdamW8bit`
   - Learning rate: `1e-4` · Text Encoder LR: `5e-5` (or 0 = off) · Unet LR: `1e-4`
   - Max resolution: `1024,1024` · Enable buckets: ✅
   - Network Rank (dim): `32` · Network Alpha: `16`
5. **Parameters → Advanced**
   - Gradient checkpointing: ✅
   - CrossAttention: `sdpa`
   - No half VAE: ✅ (avoids black images)
   - Keep n tokens: 1 (keeps trigger word first if shuffling captions)
6. **Parameters → Samples**
   - Sample every n epochs: 1
   - Prompts:
     ```
     zk3char, portrait, studio lighting --w 1024 --h 1024 --s 28 --l 6
     zk3char, full body, walking in a snowy forest --w 832 --h 1216 --s 28 --l 6
     ```
7. Click **Start training**

## 4. GUI walkthrough — FLUX.1-dev

Same as SDXL with these changes:

- Source model: tick **Flux.1** (uncheck SDXL)
  - Pretrained model: `/home/dans/train/models/flux1/flux1-dev.safetensors`
  - AE: `/home/dans/train/models/flux1/ae.safetensors`
  - CLIP-L: `/home/dans/train/models/flux1/clip_l.safetensors`
  - T5-XXL: `/home/dans/train/models/flux1/t5xxl_fp16.safetensors`
- Network rank 16, alpha 16, LR `1e-4`, **train UNet only** (no text encoder)
- **Flux.1 section:** fp8 base ✅, cache text encoder outputs ✅ (+ to disk),
  timestep sampling `shift`, discrete flow shift `3.1582`, model prediction `raw`, guidance scale `1.0`
- Resolution 1024 (or 512/768 for speed)
- If OOM: enable **blocks to swap** (e.g. 8–18) / "split mode"

Models to download (FLUX.1-dev is gated — accept license on HF):
- `black-forest-labs/FLUX.1-dev` → `flux1-dev.safetensors`, `ae.safetensors`
- `comfyanonymous/flux_text_encoders` → `clip_l.safetensors`, `t5xxl_fp16.safetensors`

---

## 5. CLI (sd-scripts, no GUI)

kohya_ss installs sd-scripts in `kohya_ss/sd-scripts`. Activate the venv first:
```bash
cd /home/dans/train/kohya_ss && source venv/bin/activate && cd sd-scripts
```

### SDXL
```bash
accelerate launch --mixed_precision bf16 sdxl_train_network.py \
  --pretrained_model_name_or_path /home/dans/train/models/sdxl/sdxl_base.safetensors \
  --train_data_dir /home/dans/train/kohya/zk3char/img \
  --output_dir /home/dans/train/output --output_name zk3char_sdxl \
  --resolution 1024,1024 --enable_bucket --caption_extension .txt \
  --network_module networks.lora --network_dim 32 --network_alpha 16 \
  --optimizer_type AdamW8bit --learning_rate 1e-4 --text_encoder_lr 5e-5 \
  --train_batch_size 1 --max_train_epochs 10 --save_every_n_epochs 2 \
  --mixed_precision bf16 --save_precision bf16 \
  --gradient_checkpointing --cache_latents --cache_latents_to_disk --sdpa --no_half_vae
```

### FLUX.1-dev
```bash
accelerate launch --mixed_precision bf16 flux_train_network.py \
  --pretrained_model_name_or_path /home/dans/train/models/flux1/flux1-dev.safetensors \
  --clip_l /home/dans/train/models/flux1/clip_l.safetensors \
  --t5xxl /home/dans/train/models/flux1/t5xxl_fp16.safetensors \
  --ae /home/dans/train/models/flux1/ae.safetensors \
  --dataset_config /home/dans/train/configs/dataset_kohya_flux1.toml \
  --output_dir /home/dans/train/output --output_name zk3char_flux1 \
  --network_module networks.lora_flux --network_dim 16 --network_alpha 16 \
  --network_train_unet_only --optimizer_type adamw8bit --learning_rate 1e-4 \
  --max_train_epochs 10 --save_every_n_epochs 2 \
  --mixed_precision bf16 --save_precision bf16 --fp8_base \
  --gradient_checkpointing --cache_latents_to_disk \
  --cache_text_encoder_outputs --cache_text_encoder_outputs_to_disk \
  --timestep_sampling shift --discrete_flow_shift 3.1582 \
  --model_prediction_type raw --guidance_scale 1.0 --sdpa
```
Add `--blocks_to_swap 8` if you get OOM.

Tip: in the GUI, **Print training command** shows the exact CLI it would run — handy for learning flags.

---

## 6. Tips

- **Black images (SDXL):** `--no_half_vae`, use bf16
- **Text encoder training on SDXL** helps likeness but overfits faster — try off first, then 5e-5
- For anime models (Illustrious/Pony) use **booru tags** in captions
- Check sd-scripts README for the current branch: FLUX support was originally on the `sd3` branch
