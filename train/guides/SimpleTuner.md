# SimpleTuner — Character LoRA guide (RTX 3090)

Repo: https://github.com/bghira/SimpleTuner · Docs: `documentation/` (QUICKSTART.md, quickstart/*.md, OPTIONS.md)

**Supports (for your list):** ✅ SDXL · ✅ FLUX.1-dev · ✅ FLUX.2 (dev / klein) · ✅ Qwen-Image (+ Z-Image, Chroma, HiDream, Wan…)
Has a **web UI** (`simpletuner server`) or a **JSON config + CLI**. Very feature-rich, more knobs than OneTrainer.

> ⚠️ Current SimpleTuner releases use **PyTorch 2.15 + CUDA 13.2**. Your 3090 is supported, but you need a
> recent NVIDIA driver that supports CUDA 13.x (`nvidia-smi` shows the max CUDA version top-right).
> Use a **separate venv** — don't share it with musubi/kohya/OneTrainer.

---

## 1. Install (Linux)

```bash
cd /home/dans/train
python3 -m venv simpletuner-venv          # Python 3.11–3.13
source simpletuner-venv/bin/activate
pip install -U pip
pip install 'simpletuner[cuda]' --extra-index-url https://download.pytorch.org/whl/cu132
huggingface-cli login                       # for gated FLUX models
```

(Git/dev install: `git clone --branch=release https://github.com/bghira/SimpleTuner.git && cd SimpleTuner && pip install -e .`)

---

## 2. Option A — Web UI (easiest)

```bash
source /home/dans/train/simpletuner-venv/bin/activate
simpletuner server
```
Open http://localhost:8001

1. Onboarding detects your GPU and configures Accelerate → accept defaults (1 GPU, bf16)
2. **Create environment** → pick **model family** (SDXL / Flux / Flux.2 / Qwen Image) → pick an **example
   recipe** with tier **`24g`** (the recipes are tuned for 24 GB cards)
3. **Dataset:** add a local dataset → folder `/home/dans/train/datasets/zk3char/images`,
   caption strategy **textfile** (uses the `.txt` next to each image)
4. Set **output dir** `/home/dans/train/output/simpletuner/zk3char_<model>`, LoRA rank 16, LR 1e-4,
   max steps ~2000, validation prompt `zk3char, portrait, studio lighting`
5. Start → watch samples in the UI
6. (Optional) CaptionFlow integration can auto-caption from the UI

## 3. Option B — Config wizard + CLI

```bash
cd /home/dans/train/configs
simpletuner configure        # interactive wizard → writes config/config.json + dataloader config
simpletuner train            # start training
```

Or write the files by hand (below) and run `simpletuner train`.

---

## 4. Hand-written config files

Put them in `/home/dans/train/configs/simpletuner/` (the wizard uses `config/` relative to where you run it).

### Dataloader — `multidatabackend.json` (same for all models, change cache dirs per model)
```json
[
  {
    "id": "zk3char",
    "type": "local",
    "instance_data_dir": "/home/dans/train/datasets/zk3char/images",
    "caption_strategy": "textfile",
    "resolution": 1024,
    "resolution_type": "pixel_area",
    "minimum_image_size": 512,
    "crop": false,
    "repeats": 10,
    "cache_dir_vae": "/home/dans/train/datasets/zk3char/cache_simpletuner/vae"
  },
  {
    "id": "text-embeds",
    "dataset_type": "text_embeds",
    "default": true,
    "type": "local",
    "cache_dir": "/home/dans/train/datasets/zk3char/cache_simpletuner/text"
  }
]
```
> Use a different `cache_simpletuner_<model>` folder per model.

### `config.json` — FLUX.2 klein 9B (recommended on 3090)
```json
{
  "model_type": "lora",
  "model_family": "flux2",
  "model_flavour": "klein-9b",
  "pretrained_model_name_or_path": "black-forest-labs/FLUX.2-klein-base-9B",
  "data_backend_config": "/home/dans/train/configs/simpletuner/multidatabackend.json",
  "output_dir": "/home/dans/train/output/simpletuner/zk3char_klein9b",
  "lora_rank": 16,
  "learning_rate": 1e-4,
  "lr_scheduler": "constant",
  "optimizer": "adamw_bf16",
  "train_batch_size": 1,
  "max_train_steps": 2000,
  "checkpointing_steps": 250,
  "gradient_checkpointing": true,
  "mixed_precision": "bf16",
  "base_model_precision": "int8-quanto",
  "validation_steps": 250,
  "validation_prompt": "zk3char, portrait, studio lighting",
  "validation_resolution": "1024x1024",
  "seed": 42
}
```
- Per docs: klein-9b ≈ **22 GB in bf16, ≈ 14 GB in int8** → on a 3090 use `int8-quanto` (or try `no_change` = bf16)
- Leave the text encoder path unset — klein uses its **bundled Qwen3** text encoder
- 64 GB system RAM recommended

### Changes for other models

| Key | SDXL | FLUX.1-dev | Qwen-Image |
|---|---|---|---|
| `model_family` | `sdxl` | `flux` | `qwen_image` |
| `model_flavour` | (omit / default) | `dev` | (default) |
| `pretrained_model_name_or_path` | `stabilityai/stable-diffusion-xl-base-1.0` | `black-forest-labs/FLUX.1-dev` | `Qwen/Qwen-Image` |
| `base_model_precision` | `no_change` | `int8-quanto` | `int8-quanto` (or lower, see guide) |
| `lora_rank` | 32 | 16 | 16 |
| `resolution` (dataloader) | 1024 | 1024 (or 512) | 768–1024 |
| extra | — | `"flux_guidance_value": 1.0` | expect slow; enable offload options from QWEN_IMAGE.md |

**Always open the matching quickstart before training** — exact key names & 24 GB tips live there:
- `documentation/quickstart/SDXL.md`
- `documentation/quickstart/FLUX.md`
- `documentation/quickstart/FLUX2.md`
- `documentation/quickstart/QWEN_IMAGE.md`
- Full option list: `documentation/OPTIONS.md` / `simpletuner train --help`

### Run
```bash
source /home/dans/train/simpletuner-venv/bin/activate
cd /home/dans/train/configs/simpletuner
simpletuner train            # reads config.json in config dir; see docs for --config path options
```

Output: checkpoints every 250 steps in `output_dir`, each with a `pytorch_lora_weights.safetensors`
(ComfyUI-compatible; convert with the repo's tools if a loader complains).

---

## 5. Tips

- **Don't use FLUX.2-dev** on one 3090 — docs require ~96 GB+ RAM and multi-GPU realistically
- `repeats` in the dataloader multiplies your small dataset; aim for ~2000 steps total
- If validation images look over-baked early, lower LR to 5e-5 or stop earlier
- SimpleTuner is the most flexible but also the most config-heavy; if it gets frustrating,
  OneTrainer or musubi-tuner reach the same result for these four models
