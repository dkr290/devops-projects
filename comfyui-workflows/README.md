# LTX-2.5 in ComfyUI – Workflows & Guidelines

Setup notes for:
- **Videos:** Linux PC, NVIDIA RTX 3090 (24 GB VRAM) + 64 GB system RAM
- **Images:** ASUS ProArt P16 (NVIDIA N1X / RTX Spark, 128 GB unified memory, Windows on ARM)

---

## 1. Workflows in this folder

| File | Purpose |
|---|---|
| `LTX-2.5_I2V_StartEnd_TwoStage_GGUF.json` | Start image (required) + end image (optional). 2-stage: low res → latent ×2 upscale + refine |
| `LTX-2.5_MSR_MultiRef_TwoStage_GGUF.json` | Up to 5 reference images (pic1–4 + background) with LiconStudio MSR V2 LoRA. 2-stage |

> These workflows have **not been tested in ComfyUI yet**; they were generated from Lightricks' official
> `LTX-2.5_T2V_I2V_Two_Stage_Distilled.json` and LiconStudio's `LTX2.5-MSR-sample-workflow-V2.json`.
> If a node shows red/missing values, compare it with those official files.

### How both workflows work
1. **Stage 1** – generate at low resolution, 8 steps (distilled model, CFG 1).
2. **Stage 2** – LTX **latent spatial upscaler ×2** + 3 refine steps (adds real detail, not just stretching).
3. **Decode** – tiled VAE decode + audio decode → MP4 with sound.

Width / height / frames / fps are set **once** (group 2). Final size = **2× stage-1 size**.

### I2V start/end workflow
- Start + end frame: load both images and run.
- Start image only: select both `END-FRAME guide` nodes → **Ctrl+B** (bypass).
- `START frame` strength stage 1: `0.7` = more motion (official default), `1.0` = exact first frame.

### MSR multi-reference workflow
- Needs custom node `ComfyUI-LTX2.5-MSR` and `LTX-2.5-Licon-MSR-V2.safetensors` in `models/loras`.
- `pic1` required; references must be contiguous (pic1, pic2, …). For fewer refs, delete the links to **both** guide nodes.
- Prompt tips:
  - Label references as `Image 1`, `Image 2`, `Image 3`…
  - Say which reference provides character / clothing / object / background.
  - Describe actions and positions ("Image 1 on the left, Image 2 on the right").
- Optional audio refs (up to 2 speakers): `Load Audio` → `LTXV Audio VAE Encode` → `audio_ref1/2` on **both** guides (paired with pic1/pic2).
- Always keep `LTXVCropGuides` before decoding (removes reference slots from the video).
- MSR uses more VRAM than plain I2V → default stage-1 size is 832×480.

---

## 2. Installation (Linux, RTX 3090)

ComfyUI Desktop is officially only Windows (NVIDIA) and macOS (Apple Silicon). On Linux use the git install:

```bash
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI
python -m venv venv && source venv/bin/activate
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
pip install -r requirements.txt
pip install -r manager_requirements.txt        # built-in Manager (newer versions)
pip install triton sageattention

cd custom_nodes
git clone https://github.com/city96/ComfyUI-GGUF && pip install -r ComfyUI-GGUF/requirements.txt
git clone https://github.com/liconstudio/ComfyUI-LTX2.5-MSR        # MSR workflow only
# optional/useful:
git clone https://github.com/Lightricks/ComfyUI-LTXVideo           # official LTX workflows/nodes
git clone https://github.com/kijai/ComfyUI-KJNodes
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite
git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation
```

Launch:
```bash
python main.py --use-sage-attention --enable-manager
# add --reserve-vram 1 if the desktop/monitor uses the same GPU
```
- Do **not** use `--highvram`. Use `--lowvram` only as last resort.
- `--fast` gives nothing on the 3090 (fp8 speedups need Ada/Blackwell).
- Make sure PyTorch CUDA version matches your driver, otherwise sage attention fails.

---

## 3. Models (3090)

Lightricks/LTX-2.5 is gated: accept license on Hugging Face, then `hf auth login`.

| Folder | File | Size | Source |
|---|---|---|---|
| `models/unet/` | `ltx-2.5-22b-distilled-Q6_K.gguf` | 17.8 GB | `unsloth/LTX-2.5-GGUF` (`distilled/`) |
| `models/text_encoders/` | `gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors` | 15.4 GB | `Lightricks/LTX-2.5` |
| `models/vae/` | `ltx-2.5-video-vae-bf16.safetensors` | 1.5 GB | `Lightricks/LTX-2.5` |
| `models/vae/` | `ltx-2.5-audio-vae-bf16.safetensors` | 0.4 GB | `Lightricks/LTX-2.5` |
| `models/latent_upscale_models/` | `ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors` | 1.0 GB | `Lightricks/LTX-2.5` |
| `models/loras/` | `LTX-2.5-Licon-MSR-V2.safetensors` | 2.2 GB | `LiconStudio/LTX-2.5-Multiple-Subject-Reference` |

### GGUF choice (distilled, quality vs bf16 from unsloth's table)
| File | Size | Notes |
|---|---|---|
| `Q8_0` | 22.8 GB | closest to bf16, heavy for 24 GB |
| `Q6_K` | 17.8 GB | **default** – very good quality |
| `UD-Q5_K_XL` | 16.0 GB | good compromise |
| `UD-Q4_K_XL` | 14.0 GB | unsloth's recommendation for most GPUs |
| `UD-Q3_K_XL` / `UD-Q2_K_XL` | 12 / 9.5 GB | emergency only |

- Prefer `UD-` variants over plain `Q4_K_M` / `Q3_K_M` at the same size.
- Text encoder: int8 version (3090 has int8 tensor cores). Don't use the 26 GB bf16 one on 24 GB.
- **Skip `nvfp4`** files on the 3090 – Blackwell only (good for the N1X laptop).

---

## 4. Resolution & length rules

- Width/height **divisible by 32**.
- Frames = **8n + 1**: 97 (≈4 s), 121 (≈5 s), 161 (≈6.7 s) at 24 fps.

| Stage 1 | Final (×2) | Use |
|---|---|---|
| 768×448 | 1536×896 | fast tests / finding seeds & prompts |
| **960×544** | **1920×1088** | default 16:9 1080p (crop to 1920×1080) |
| 544×960 | 1088×1920 | vertical |
| 832×480 | 1664×960 | MSR default |
| 1280×704 | 2560×1408 | upper limit on 3090; may need Q5/Q4 + small tiles |

Recommended routine:
1. Find seed + prompt at 768×448 (fast, seed = randomize).
2. Fix the seed, render at 960×544 → 1920×1088.
3. Optional 4K / smoother motion (section 6).

---

## 5. Out of memory / slow – checklist (3090)

1. VAE Decode (Tiled) `tile_size` 512 → 384 → 256.
2. Smaller GGUF (UD-Q5_K_XL → UD-Q4_K_XL).
3. Fewer frames (121 → 97).
4. Smaller stage-1 resolution.
5. MSR: fewer reference images.
6. `--reserve-vram 1`, close browser tabs with GPU acceleration.
7. Watch the console: **"loaded partially"** = model didn't fit in VRAM → slow. Fix with steps 2–4.

64 GB system RAM is enough for offloaded parts; 32 GB would swap.

---

## 6. Upscaling beyond 1080p (optional)

| Method | Quality | Speed | Notes |
|---|---|---|---|
| Lightricks `LTX-2.5_V2V_TiledFusion_Upscale.json` | best LTX-native | slow | FullHD/4K/8K, in `ComfyUI-LTXVideo/example_workflows/2.5` |
| SeedVR2 | very good, temporally consistent | slow | use its block swap on 3090, process in frame batches |
| `Upscale Image (using Model)` + 4x-UltraSharp / RealESRGAN | ok | fast | per frame → slight flicker |
| RIFE / FILM (Frame-Interpolation) | – | fast | 24 → 48 fps for smoother motion |

Save with VHS Video Combine (H.264/H.265, CRF 16–18) or native Save Video.

---

## 7. Coming from Wan2GP – what replaces what

| Wan2GP | ComfyUI |
|---|---|
| mmgp offloading / profiles | ComfyUI smart memory, Kijai WanVideoWrapper block swap, ComfyUI-MultiGPU DisTorch |
| int8/fp8 quantization | fp8 "scaled" / int8 checkpoints, GGUF via ComfyUI-GGUF |
| Sage attention | `--use-sage-attention` |
| TeaCache | TeaCache / MagCache nodes (KJNodes, WanVideoWrapper) |
| Distilled LoRAs (Lightx2v, CausVid) | same LoRAs, 4–8 steps, CFG 1 |
| VAE tiling | VAE Decode (Tiled) |
| compile | TorchCompile nodes (needs Triton) |

Wan on 3090: fp8 or GGUF Q8 14B, block swap ~20 at 720p (reduce until OOM), fp8 umt5 text encoder. Wan 2.2 14B uses two models (high/low noise) → needs lots of system RAM (64 GB).

---

## 8. ComfyUI Manager notes

- ComfyUI Desktop already **includes** the Manager – don't clone `ComfyUI-Manager` into `custom_nodes` too (conflicts).
- "not allowed with this security level": edit `user/default/ComfyUI-Manager/config.ini` (or `user/__manager/config.ini`) → `security_level = normal` (or `weak` for git URL installs).
- Git must be installed and on PATH.
- Desktop uses its own `.venv`; install pip packages from Desktop's built-in terminal, not system Python.
- Git install: run with `--enable-manager`.

---

## 9. Images on the ASUS ProArt P16 (N1X, 128 GB unified)

Memory **size** is no problem; memory **bandwidth** (~273 GB/s vs 936 GB/s on 3090) is the bottleneck → use it for images, 3090 for video.

- **Turn off** memory tricks: no block swap, no `--lowvram`/`--reserve-vram`, no small GGUF just to fit, no tiled VAE needed.
- **Use fp8 / NVFP4** models – Blackwell has hardware support, they are *faster* here, not just smaller. `--fast` helps.
- Use turbo / lightning / distilled image models & LoRAs (fewer steps = biggest speedup).
- Leave ~16–20 GB for Windows + apps (shared memory).
- Laptop: plug in, MyASUS/Creator Hub **Performance** mode; long jobs will thermal-throttle.
- Windows on ARM caveats:
  - Need native **ARM64 + CUDA** PyTorch (x86 emulation can't use CUDA).
  - Check whether ComfyUI Desktop has an ARM64 build; otherwise use manual install per NVIDIA/ComfyUI guidance.
  - Sage attention / Triton / TorchCompile may not exist yet → PyTorch SDPA attention is fine.
  - Custom nodes with compiled x86 wheels (InsightFace etc.) may fail; pure-Python nodes usually work.

### Using both machines
- Make images on the laptop → use as start/end frames on the 3090.
- Shared folder, or run 3090 ComfyUI with `--listen` and open it from the laptop browser (trusted network only).
