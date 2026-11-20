# OneTrainer — Character LoRA guide (RTX 3090)

Repo: https://github.com/Nerogar/OneTrainer · Wiki: https://github.com/Nerogar/OneTrainer/wiki

**Why OneTrainer:** one tool for **all four** of your models — SDXL, FLUX.1-dev, FLUX.2 (dev / klein),
Qwen-Image (plus Z-Image, Chroma, SD3.5…). Has a GUI **and** a CLI, built-in captioning (BLIP/BLIP2/WD14),
masked training, sampling during training, TensorBoard, automatic backups.

---

## 1. Install (Linux)

Requires **Python ≥ 3.11.1 and < 3.14**.

```bash
sudo apt-get update && sudo apt-get install -y libgl1 python3-tk git
cd /home/dans/train
git clone https://github.com/Nerogar/OneTrainer.git
cd OneTrainer
./install.sh
```

Update later: `./update.sh`

## 2. Start

```bash
cd /home/dans/train/OneTrainer
./start-ui.sh
```

---

## 3. GUI walkthrough (same flow for every model)

### Step 1 — Preset (top left)
Pick the preset matching your model + LoRA, e.g.:

| Model | Preset (name may vary slightly by version) |
|---|---|
| SDXL / Illustrious / Pony | `#sdxl 1.0 LoRA` |
| FLUX.1-dev | `#flux LoRA` (choose the 24 GB variant if present) |
| FLUX.2 klein 9B | `#flux 2 ... LoRA` / klein preset |
| Qwen-Image | `#qwen ... LoRA` (24 GB variant if present) |

Then **save as your own preset** (e.g. `zk3char_klein`) so you don't lose your changes.

### Step 2 — General tab
- **Workspace directory:** `/home/dans/train/output/onetrainer/zk3char_<model>` (new empty folder per run)
- **Cache directory:** `/home/dans/train/datasets/zk3char/cache_onetrainer_<model>` (separate per model!)
- Enable **TensorBoard** (optional, to watch loss + samples)

### Step 3 — Model tab
- **Base model:** HF repo id, local `.safetensors`, or diffusers folder:

| Model | Base model |
|---|---|
| SDXL | `stabilityai/stable-diffusion-xl-base-1.0` or `/home/dans/train/models/sdxl/<file>.safetensors` |
| FLUX.1-dev | `black-forest-labs/FLUX.1-dev` |
| FLUX.2 klein 9B | `black-forest-labs/FLUX.2-klein-base-9B` (train on **base**, not the distilled one) |
| Qwen-Image | `Qwen/Qwen-Image` |

- **Weight data types (3090):**
  - SDXL: everything `bfloat16`
  - FLUX.1 / klein 9B: transformer `float8` (or `bfloat16` for klein if it fits), text encoder `float8`/`bfloat16`
  - Qwen-Image: transformer `float8` (or lower / NF4 option if offered), text encoder `float8`
- **Output:** `/home/dans/train/output/zk3char_<model>.safetensors`, format `safetensors`, data type `bfloat16`

### Step 4 — Data tab
- Aspect ratio bucketing: **on**
- Latent caching: **on**
- Clear cache before training: on (only if you changed images/captions)

### Step 5 — Concepts tab
1. **Add concept** → click it
2. **Path:** `/home/dans/train/datasets/zk3char/images`
3. **Prompt source:** `From text file per sample` (uses `001_x.png` ↔ `001_x.txt`)
4. **Repeats / balancing:** 1 (control length via epochs instead)
5. Augmentation tab: leave **crop jitter on**, turn **flip OFF** for characters with asymmetric features
   (hair parting, tattoos, logos)

Optional: **Tools → Dataset Tools / Caption** to auto-caption or fix captions in a GUI.

### Step 6 — Training tab (starting values)

| Setting | SDXL | FLUX.1-dev | FLUX.2 klein 9B | Qwen-Image |
|---|---|---|---|---|
| Optimizer | AdamW8bit (or Prodigy, LR 1) | AdamW8bit | AdamW8bit | AdamW8bit |
| Learning rate | 1e-4 | 1e-4 | 1e-4 | 1e-4 |
| Text encoder training | off (or 5e-5) | off | off | off |
| Epochs (≈25 imgs) | 80–100 | 80–100 | 80–100 | 80–120 |
| Batch size | 1–2 | 1 | 1 | 1 |
| Resolution | 1024 | 512,768,1024 | 768,1024 | 768 (1024 if fits) |
| Train data type | bfloat16 | bfloat16 | bfloat16 | bfloat16 |
| Gradient checkpointing | ON | ON | ON | ON (+ CPU offload / layer offload if offered) |
| Approx. time on 3090 | 30–60 min | 1–2 h | ~1 h | 2–5 h |

Target ≈ **1500–3000 steps** total (steps = images × epochs / batch size).

### Step 7 — LoRA tab
- Rank **16**, Alpha **16** (SDXL: rank 32, alpha 16)
- Type: LoRA (LoHa/LoKr possible, not needed)

### Step 8 — Sampling tab
- Sample every **250 steps** (or every N epochs)
- Prompts (always with trigger word):
  ```
  zk3char, portrait, studio lighting
  zk3char, full body, walking in a snowy forest, winter coat
  zk3char, sitting in a cafe, laughing, cinematic
  ```

### Step 9 — Backup tab
- Backup / save every **N epochs** so you can pick the best checkpoint (often 60–80 % of the run)

### Step 10 — Start Training (bottom right)

---

## 4. CLI mode (no GUI)

All scripts live in `scripts/`; run inside the venv.

```bash
cd /home/dans/train/OneTrainer
source venv/bin/activate

# Easiest: build & save the config once in the GUI ("Export" / save preset → JSON), then:
python scripts/train.py --config-path /home/dans/train/configs/onetrainer_zk3char_klein.json

# Other useful scripts
python scripts/generate_captions.py -h      # auto-captions
python scripts/generate_masks.py -h         # masks for masked training
python scripts/sample.py -h                 # generate test images
python scripts/train.py -h                  # all options
```

Save configs to `/home/dans/train/configs/` so every run is reproducible.

---

## 5. Tips for 3090

- OOM → lower resolution, set transformer to `float8`, enable layer/CPU offload, close the browser
- Very slow on Qwen → that's normal (20B); try resolution 768
- Use **masked training** if backgrounds keep leaking into the LoRA
  (generate masks with Tools → ClipSeg/Rembg, enable "Masked training" in Training tab)
- Debug report for issues: `./run-cmd.sh generate_debug_report`
