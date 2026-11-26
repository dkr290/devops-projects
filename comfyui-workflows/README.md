# ComfyUI Video & Audio Workflows Guide (RTX 3090 & RTX Spark)

Complete guide for all **23 workflows** organized by model family (`LTX/`, `Minimax/`, `WAN/`, `HunyuanVideo1.5/`, `Audio/`, `Image/`). Every workflow also includes built-in **`HOW TO`** note panels directly inside ComfyUI.

Setup notes cover:
- **Videos:** Linux PC, NVIDIA RTX 3090 (24 GB VRAM) + 64 GB system RAM
- **Images / Portable tests:** NVIDIA RTX Spark (N1X, 128 GB unified memory, Windows on ARM)
- **Helper files in this folder:** [`start-comfy.sh`](start-comfy.sh) (launch command) and [`Compile-sage-linux.md`](Compile-sage-linux.md) (compiling SageAttention on Linux for RTX 3090 / CUDA 13)

---

## 1. Which Workflow Should You Use?

### LTX-2.5 & LTX-2.3 (`LTX/` — 11 workflows)

| Workflow | Best For | Stages / Steps | Default Images / Inputs | Audio |
|---|---|---|---|---|
| [`LTX/LTX-2.5_I2V_DFR_SingleImage_Audio_GGUF.json`](LTX/LTX-2.5_I2V_DFR_SingleImage_Audio_GGUF.json) | **Official LTX-2.5 DFR** (Diffusion Fidelity Rendering) — highest detail/sharpness single-image I2V (or T2V) using detailing keyframes + Pixel-Spatial IC-LoRA | **2-stage DFR ON** (8 + 3 steps) + **optional Stage 3 Temporal ×2** (48 fps, OFF by default) | **1 ON** (`Start image`; or `Switch to T2V` inside subgraph) | Native synchronized audio generated in Stage 1 |
| [`LTX/LTX-2.5_I2V_PromptRelay_OptionalTwoStage_GGUF.json`](LTX/LTX-2.5_I2V_PromptRelay_OptionalTwoStage_GGUF.json) | **Kijai Prompt Relay (Smart)** — multi-event temporal prompting (`Scene 1:` / `Scene 2:` / `Scene 3:` or `A \| B \| C`) pasted straight from LM Studio for **1 image** or **2–4 images** | **1-stage or 2-stage** (`RUN STAGE 2?` toggle; Prompt Relay on Stage 1) | **1 ON** (`START`); `END`, `MID-A`, `MID-B` bypassed (Ctrl+B to enable) | Optional dialog audio (auto-fitted & locked) |
| [`LTX/LTX-2.5_I2V_LTXDirector_OptionalTwoStage_GGUF.json`](LTX/LTX-2.5_I2V_LTXDirector_OptionalTwoStage_GGUF.json) | **Visual timeline** with **3, 4, or more images**, different prompts per time segment (Prompt Relay), drag-and-drop audio, and automatic last-frame PNG save | **1-stage or 2-stage** (`RUN STAGE 2?` toggle) | Drag & drop as many as you want | Built into Director (`use_custom_audio`) |
| [`LTX/LTX-2.5_I2V_ThreeKeyframes_ManualContinuation_GGUF.json`](LTX/LTX-2.5_I2V_ThreeKeyframes_ManualContinuation_GGUF.json) | **Ready-to-run 3-image** workflow (`START` + `MIDDLE` + `END`, optional 4th `MID-B`), saves last decoded frame PNG for manual multi-clip continuation | **1-stage or 2-stage** (`RUN STAGE 2?` toggle) | **3 ON** (`START`, `MIDDLE @ 96`, `END @ -1`); `MID-B @ 144` bypassed | Optional full-track audio + `TrimAudioDuration` (`AUDIO START`) |
| [`LTX/LTX-2.5_I2V_Keyframes_Dialog_OptionalTwoStage_GGUF.json`](LTX/LTX-2.5_I2V_Keyframes_Dialog_OptionalTwoStage_GGUF.json) | Clean general-purpose **1–4 image** keyframe workflow with fast 1-stage draft or 2-stage final toggle | **1-stage or 2-stage** (`RUN STAGE 2?` toggle) | **2 ON** (`START`, `END`); `MID-A` & `MID-B` bypassed | Optional dialog audio (auto-fitted & locked) |
| [`LTX/LTX-2.5_I2V_Keyframes_Dialog_SingleStage_GGUF.json`](LTX/LTX-2.5_I2V_Keyframes_Dialog_SingleStage_GGUF.json) | Pure **1-stage only** (no spatial upscaler model needed at all), up to 4 images | **1-stage only** | **2 ON** (`START`, `END`); `MID-A` & `MID-B` bypassed | Optional dialog audio (auto-fitted & locked) |
| [`LTX/LTX-2.5_MSR_MultiRef_TwoStage_GGUF.json`](LTX/LTX-2.5_MSR_MultiRef_TwoStage_GGUF.json) | **MSR multi-subject reference** (up to `pic1–4` + `background`) with LiconStudio MSR V2 LoRA to lock character/object identities | **2-stage** (8 + 3 steps) | Up to **5 semantic refs** (`pic1–4` + `background`) | Native audio + optional `audio_ref1/2` voice refs |
| [`LTX/LTX-2.5_MSR_Keyframes_Dialog_TwoStage_GGUF.json`](LTX/LTX-2.5_MSR_Keyframes_Dialog_TwoStage_GGUF.json) | **MSR identity refs + keyframes + dialog** (`pic1–3` + START/MID-A/MID-B/END) | **2-stage** (8 + 3 steps) | `pic1–3` + START/END ON (`MID-A/B` bypassed) | Optional dialog audio (auto-fitted & locked) |
| [`LTX/LTX-2.5_MSR_Keyframes_Dialog_SingleStage_GGUF.json`](LTX/LTX-2.5_MSR_Keyframes_Dialog_SingleStage_GGUF.json) | Same MSR + keyframes + dialog workflow, **1-stage only** | **1-stage only** | `pic1–3` + START/END ON (`MID-A/B` bypassed) | Optional dialog audio (auto-fitted & locked) |
| [`LTX/LTX-2.5_V2V_TiledFusion_4K_Upscale_GGUF.json`](LTX/LTX-2.5_V2V_TiledFusion_4K_Upscale_GGUF.json) | **V2V 4K / FullHD / 8K Video Upscaler** (Lightricks Tiled Fusion + Refine Details IC-LoRA) — upscales any rendered MP4 (from LTX, Pika/MiniMax, Wan, or Hunyuan) | **8 fused steps** (`LTXVTiledFusionSampler`, `HD` or `qHD` tiles) | **1 Video MP4** (`LoadVideo`) + style-only prompt | Preserves original video audio |
| [`LTX/LTX-2.3_I2V_ICLoRA_MotionControl_DepthUnion.json`](LTX/LTX-2.3_I2V_ICLoRA_MotionControl_DepthUnion.json) | **LTX-2.3 Image + Motion Video Control** (`IC-LoRA Union Control` — Depth via built-in MoGe 2, swappable with Canny/Pose) — 100% native ComfyUI | **8 steps** distilled (`ltx-2.3-22b-distilled-fp8`) | **1 First Frame** + **1 Control Video** (`LoadVideo` → `Video Slice` → MoGe Depth) | Native synchronized audio |

### MiniMax H3 & Pika H3 Flex (`Minimax/` — 5 workflows)

| Workflow | Best For | Stages / Steps | Default Images / Inputs | Audio |
|---|---|---|---|---|
| [`Minimax/Pika-H3-Flex_Ref2VA_MultiRef_6Step.json`](Minimax/Pika-H3-Flex_Ref2VA_MultiRef_6Step.json) | **Pika H3 Flex multi-reference** (`<Picture 1..3>`, up to 9 images + audio) distilled to 6 steps (`lcm` + `ManualSigmas`), works up to `1344×768`, optional bypassed Start/End pins — 100% native ComfyUI `0.44.0+` | **6 steps** (`pika_h3_flex_ref2va_v1_bf16`) | **3 semantic refs ON** (`<Picture 1..3>`); Start/End pins bypassed | Native stereo speech/SFX/music + optional `<Audio 1>` ref |
| [`Minimax/Pika-H3-Flex_Ref2VA_ImagePlusMotionVideo_6Step.json`](Minimax/Pika-H3-Flex_Ref2VA_ImagePlusMotionVideo_6Step.json) | **Image + Motion Reference Video (`<Video 1>`)** — transfer body motion, timing & camera moves from any 2–15 s clip onto your character image (**0 new models** over Ref2VA!) — 100% native ComfyUI `0.44.0+` | **6 steps** (`pika_h3_flex_ref2va_v1_bf16`) | **1–2 images** (`<Picture 1..2>`) + **1 motion video** (`<Video 1>`, `Video Slice`); optional bypassed Start pin | Native stereo audio (or link `GetVideoComponents.audio` → `ref_video_audio_0`) |
| [`Minimax/MiniMax-H3_FunControlNet_PosePlusImage.json`](Minimax/MiniMax-H3_FunControlNet_PosePlusImage.json) | **Exact Skeleton-Locked Pose Transfer + Character Image** (built-in **SDPose** wholebody extractor + `MiniMaxH3FunControlNetApply` Union patch — best for strict dance/choreography) — 100% native ComfyUI `0.35.0+` | **4-step Turbo ON** (toggle OFF → 20-step base) | **1 image** (`<Picture 1>`) + **1 pose control video** (`LoadVideo` → SDPose) | Native stereo audio |
| [`Minimax/Pika-H3-Flex_FL2VA_FirstLast_6Step.json`](Minimax/Pika-H3-Flex_FL2VA_FirstLast_6Step.json) | **Pika H3 Flex First & Last Frame** (or 1-image Start-Only I2V by unlinking `last_frame`) distilled to 6 steps — 100% native ComfyUI `0.44.0+` | **6 steps** (`pika_h3_flex_fl2va_v1_bf16`) | **2 ON** (`First frame` + `Last frame`; unlink `last_frame` for 1-image I2V) | Native stereo speech/SFX/music |
| [`Minimax/MiniMax-H3_Ref2VA_MultiChar_4StepTurbo.json`](Minimax/MiniMax-H3_Ref2VA_MultiChar_4StepTurbo.json) | **Fastest 4-step Ref2VA draft** (`<Picture 1..3>`) + 1-click toggle to **20-step base** + optional bypassed Start/End timeline guides | **4-step Turbo ON** (`4-STEP TURBO?` toggle → 20-step base) | **3 semantic refs ON** (`<Picture 1..3>`); Start/End timeline guides bypassed | Native stereo speech/SFX + optional `<Audio 1>` voice timbre ref |

### Wan 2.2 14B (`WAN/` — 2 workflows) & HunyuanVideo 1.5 (`HunyuanVideo1.5/` — 1 workflow)

| Workflow | Best For | Stages / Steps | Default Images / Inputs | Audio |
|---|---|---|---|---|
| [`WAN/Wan2.2_14B_I2V_FLF_4StepLightX2V.json`](WAN/Wan2.2_14B_I2V_FLF_4StepLightX2V.json) | **Fast Wan 2.2 First-Last Frame** (action shots, strong physics, huge LoRA ecosystem) — 100% native ComfyUI | **4 steps** (2 High + 2 Low LightX2V) | **2 ON** (`START` + `END`; unlink `end_image` for 1-image I2V) | Video only + optional bypassed `LoadAudio` mux |
| [`WAN/Wan2.2_14B_I2V_FLF_8StepOrBase20Step.json`](WAN/Wan2.2_14B_I2V_FLF_8StepOrBase20Step.json) | **Higher-quality Wan 2.2 FLF** with 1-click toggle between **8-step LightX2V LoRA** and **20-step Base** (auto High/Low split + CFG + shift) | **8-step LoRA ON** (`USE 8-STEP LORA?` → 20-step base) | **2 ON** (`START` + `END`; unlink `end_image` for 1-image I2V) | Video only + optional bypassed `LoadAudio` mux |
| [`HunyuanVideo1.5/HunyuanVideo-1.5_I2V_FastDistilled.json`](HunyuanVideo1.5/HunyuanVideo-1.5_I2V_FastDistilled.json) | **Lightweight 8.3B cinematic I2V** (~9 GB in FP8) with strong physics & lighting — 100% native ComfyUI | **12 steps** step-distilled (8–12 rec.; swap to 720p base @ 20–50 steps) | **1 ON** (`START` image) | Video only + optional bypassed `LoadAudio` mux |

### Audio (`Audio/` — 2 workflows)

| Workflow | Best For | Speed / VRAM | Inputs | Output |
|---|---|---|---|---|
| [`Audio/Audio_Qwen3TTS_VoiceClone_TTSSuite.json`](Audio/Audio_Qwen3TTS_VoiceClone_TTSSuite.json) | **Voice cloning & dialogue TTS** from a 3–15 s sample (or preset speakers / voice design / `[Alice]` multi-character scripts) | Fast (~4–6 GB VRAM) | 3–15 s reference voice + transcript + script | Clean FLAC/WAV voice for LTX-2.5 lip-sync & DaVinci Resolve |
| [`Audio/Audio_ACEStep15_TextToMusic.json`](Audio/Audio_ACEStep15_TextToMusic.json) | **Text-to-Music & background scores** (instrumental or vocal songs with lyrics, up to 10 min) — 100% native ComfyUI | **8 steps** Turbo (<10 s on 3090, <4 GB VRAM) | Style tags + lyrics (`[Instrumental]` default) + duration | Studio FLAC/MP3 music for Resolve or Wan/Hunyuan mux |

### Image Prep & Scaling (`Image/` — 2 workflows)

| Workflow | Best For | Speed / Models | Controls | Output |
|---|---|---|---|---|
| [`Image/Image_Downscale_Prep_For_FluxQwen.json`](Image/Image_Downscale_Prep_For_FluxQwen.json) | **Downscale already-generated 2K/4K characters or backgrounds** to ~1 MP (`768×1344` / `1344×768`) before merging in FLUX.2 / Qwen-Image-Edit — 100% native ComfyUI | Instant (<1 s), **no models** | `USE EXACT WIDTH/HEIGHT?` toggle (OFF = auto `1.0 MP` ÷64; ON = custom `W×H`) | Clean lossless PNG (`Image_Prep_1MP_*.png`) |
| [`Image/Image_Upscale_Final_After_FluxQwen.json`](Image/Image_Upscale_Final_After_FluxQwen.json) | **Optional post-FLUX.2 / post-Qwen upscaler** for your final merged `16:9` still (only when needed for LTX 1080p or high-res stills) — 100% native ComfyUI | Fast; optional `models/upscale_models/` (e.g. `4x-UltraSharp.pth`) | `USE UPSCALE MODEL?` (AI Model vs No-Model `lanczos`) + `FIT TO TARGET SIZE?` (`1920×1088` vs raw 4×) | Clean lossless PNG (`Image_Upscaled_Final_*.png`) |

> **Is 2-stage mandatory in LTX-2.5?** **No.** 1-stage works great for fast renders and moderate resolutions (up to ~`768×768` or `960×544`). Use **2-stage** (or **DFR**) when you want `1024×1024` or `1080p` (`1920×1088`) on a 24 GB RTX 3090 — generating motion at low resolution and refining at ×2 is sharper, more stable, and safer on VRAM.

---

## 2. Image Prep & Dimensions Best Practices (FLUX.2 / Qwen → Video I2V)

When building scenes from multiple images (e.g., generating a **9:16 full-body character** + a **16:9 background**, merging them in **FLUX.2** or **Qwen-Image-Edit**, and animating the final still in **LTX-2.5 / Pika H3 Flex / Wan / Hunyuan**), **never upscale intermediate images**.

### Why upscaled inputs make multi-image merging very slow
In **FLUX.2** and **Qwen-Image-Edit**, every input reference image is encoded into visual tokens. Feeding upscaled 2K–4K character/background images multiplies the token count and attention compute dramatically (`O(n²)`) — making generation several times slower with **no real quality gain**, because both models' native sweet spot is **~1 MP** (`~1024×1024` pixel area).

### Recommended Pipeline & Dimensions (for 16:9 Video)

| Step | Aspect Ratio | Recommended Size | Upscale? | Notes |
|---|---|---|---|---|
| **1. Character ref (full body)** | `9:16` | **`768×1344`** *(or `720×1280`)* | **No** | Native ~1 MP (`÷64` friendly); sharp face & outfit details without blowing up token count |
| **2. Background / location ref** | `16:9` | **`1344×768`** *(or `1280×720`)* | **No** | Native ~1 MP; matches final video aspect ratio |
| **3. Merged scene + Mid/End keyframes** *(FLUX.2 / Qwen-Image-Edit)* | `16:9` | **`1344×768`** *(or `1280×704`)* | **No** | Fast merging & best identity coherence; keep all keyframes for a clip at the **exact same 16:9 size** |
| **4. Final still → Video I2V** | `16:9` | **`1344×768`** *(or `1920×1088` for LTX 1080p)* | **Usually No** *(max 1080p)* | See model rules below — **do not feed 4K stills into I2V** |
| **5. Final Video Upscale** *(optional)* | `16:9` | `1920×1088` → `4K` | **Yes, here** | Upscale **after** the video is rendered (see Section 7: LTX TiledFusion / SeedVR2 / DaVinci Resolve) |

*(For vertical **9:16** videos, simply flip the Step 2–4 dimensions to `768×1344` / `896×1536` / `1088×1920`.)*

### Practical Rules
1. **Already generated 2K/4K characters you love? Downscale them — do NOT regenerate at lower res with the same seed:**
   * Changing width/height alters the latent noise shape, so the same seed produces a **different face/pose/outfit**.
   * Downscaling with [`Image/Image_Downscale_Prep_For_FluxQwen.json`](Image/Image_Downscale_Prep_For_FluxQwen.json) preserves **100% of your exact character**, runs in <1 second, and looks clean/supersampled (`area` resampling to `1.0 MP` ÷64: `9:16` → `768×1344`, `16:9` → `1344×768`).
   * Only generate directly at `768×1344` / `1344×768` for **new** characters and backgrounds going forward.
2. **Always match the video's aspect ratio (`16:9`) on the final merged image:** If you feed a `9:16` portrait directly into a `16:9` video workflow, it will either center-crop off the character's head/feet or distort framing. Always compose the final Start/Mid/End stills in **`16:9`** first.
3. **Should you upscale the final merged still right before Video I2V?**
   * **Pika H3 Flex / MiniMax H3:** **No.** Native max is `1344×768` — your `1344×768` merged still is already exact 1:1.
   * **Wan 2.2 / HunyuanVideo 1.5:** **No.** They run at `832×480`–`1280×720` and downscale anything larger.
   * **LTX-2.5 DFR (`1280×704`) / 2-stage (`1536×896`):** **No** — `1344×768` works directly.
   * **LTX-2.5 2-stage Full HD (`960×544 → 1920×1088`) or standalone high-res stills:** Use [`Image/Image_Upscale_Final_After_FluxQwen.json`](Image/Image_Upscale_Final_After_FluxQwen.json) (1-click If/Else between **AI upscale model** like `4x-UltraSharp.pth` and **No-Model `lanczos`**, plus `FIT TO TARGET SIZE?` = ON for supersampled `1920×1088` video-ready PNG, or OFF for raw 4× still). Never feed 4K into Video I2V — upscale the rendered video instead (Section 7).

### Recommended Image Upscaling Models (`ComfyUI/models/upscale_models/`)

All models below work natively in ComfyUI via `UpscaleModelLoader` + `ImageUpscaleWithModel` (Spandrel backend) inside [`Image/Image_Upscale_Final_After_FluxQwen.json`](Image/Image_Upscale_Final_After_FluxQwen.json). Browse downloads and visual comparisons on [OpenModelDB](https://openmodeldb.info/).

#### Best for Photorealistic Characters, Skin & FLUX / Qwen Scenes
| Model | Scale | Speed | Best For |
|---|---|---|---|
| **`4x_NMKD-Siax_200k.pth`** | 4× | Fast | **Top realistic default** — natural skin texture & balanced sharpness without plastic/oversharpened look |
| **`4xNomos8kSC.pth`** / **`4xNomos8kDAT.pth`** / **`4xNomos8k_atd_jpg.safetensors`** | 4× | Medium / Slow (DAT/ATD) | State-of-the-art realistic hair, fabric, eyes, and natural grain (`DAT`/`ATD` = highest fidelity, slower) |
| **`2xNomosUni_esrgan_multijpg.pth`** *(or **`2xHFA2kAVCOCompact.pth`**)* | 2× | Very Fast | **Best 2× pick for `1344×768` → `1920×1088`** — avoids overshooting to 5K before downscaling |
| **`4xFaceUpDAT.pth`** / **`4xFaceUpSharpDAT.pth`** | 4× | Slow | Specialized for realistic faces, eyes, and fine skin pores |
| **`4x-ClearRealityV1.pth`** | 4× | Fast | Very clean photorealism with strong artifact/noise cleanup |

#### All-Round / General Purpose
| Model | Scale | Speed | Best For |
|---|---|---|---|
| **`4x-UltraSharp.pth`** *(or **`4x-UltraSharpV2.pth`**)* | 4× | Fast | Classic crisp ComfyUI default — great when supersampled down to `1920×1088` (`FIT TO TARGET SIZE?` ON); raw 4× can look slightly sharp on soft skin |
| **`4x_foolhardy_Remacri.pth`** | 4× | Fast | Balanced detail + natural texture; great all-rounder for photos and realistic renders |
| **`RealESRGAN_x4plus.pth`** | 4× | Fast | Clean, smooth baseline with strong denoising (slightly softer than UltraSharp/Nomos) |

#### Anime, 2D & Stylized 3D Illustration
| Model | Scale | Speed | Best For |
|---|---|---|---|
| **`4x-AnimeSharp.pth`** | 4× | Fast | Crisp cel-shaded lines and stylized 3D renders |
| **`RealESRGAN_x4plus_anime_6B.pth`** | 4× | Very Fast | Lightweight, clean 2D anime linework |
| **`4x_NMKD-Superscale-SP_178000_G.pth`** | 4× | Fast | Clean general illustration & 3D renders |

#### Fast / Lightweight (Great on RTX Spark N1X or Batch Runs)
| Model | Scale | Speed | Best For |
|---|---|---|---|
| **`4xNomos2_hq_mosr.pth`** *(MoSR)* / **`4xNomosUni_span_multijpg.pth`** *(SPAN)* | 4× | Ultra-Fast | Modern lightweight architectures — close to ESRGAN/Nomos quality at a fraction of the time |

> **Pixel upscaler vs. Diffusion upscaler:** The models above sharpen and enlarge existing pixels in 1–5 seconds without changing the character's face. If a source still is genuinely blurry and you want to *re-imagine* brand-new pores/textures, use a **diffusion upscaler** instead (e.g. **SeedVR2**, **SUPIR**, or **Ultimate SD Upscale + FLUX** at low denoise `0.2–0.35`).

---

## 3. LTX-2.5 Setup & Usage (`LTX/`)

### Custom Nodes (`ComfyUI/custom_nodes/`)
* **All 10 LTX-2.5 workflows:** [`ComfyUI-GGUF`](https://github.com/city96/ComfyUI-GGUF) (`UnetLoaderGGUF`)
* **DFR workflow (`LTX-2.5_I2V_DFR_SingleImage_Audio_GGUF.json`):** Requires recent ComfyUI (`0.44.0+` recommended) with native DFR nodes (`LTXVAddGeneratedKeyframes`, `LTXVAddLatentGuide`, `LTXVFreezeLatent`).
* **Tiled Fusion 4K Upscale (`LTX-2.5_V2V_TiledFusion_4K_Upscale_GGUF.json`):** Latest [`Lightricks/ComfyUI-LTXVideo`](https://github.com/Lightricks/ComfyUI-LTXVideo) (`LTXVTiledFusionSampler`, `LTXICLoRALoaderModelOnly`).
* **Prompt Relay workflow (`LTX-2.5_I2V_PromptRelay_OptionalTwoStage_GGUF.json`):** [`ComfyUI-PromptRelay`](https://github.com/kijai/ComfyUI-PromptRelay) (`PromptRelaySmartEncode`) — supports both LTX (video + audio cross-attention) and Wan; do not stack with LTX Director.
* **LTX Director workflow only:** [`WhatDreamsCost-ComfyUI`](https://github.com/WhatDreamsCost/WhatDreamsCost-ComfyUI) (latest v2.0+ with `LTXDirector`, `LTXDirectorGuide`, `LTXDirectorCropGuides`) + up-to-date ComfyUI & [`ComfyUI-LTXVideo`](https://github.com/Lightricks/ComfyUI-LTXVideo)
* **MSR workflows (`LTX-2.5_MSR_*`) only:** [`ComfyUI-LTX2.5-MSR`](https://github.com/liconstudio/ComfyUI-LTX2.5-MSR)

### Model Files
Lightricks/LTX-2.5 is gated on Hugging Face: accept the license, then run `hf auth login`.

| ComfyUI Folder | File | Size | Used By |
|---|---|---:|---|
| `models/unet/` | `ltx25_uncensored_v1.1-Q6_K.gguf` *(or official `ltx-2.5-22b-distilled-Q6_K.gguf` from `unsloth/LTX-2.5-GGUF`)* | 17.8 GB | All LTX-2.5 workflows *(for DFR, A/B test official distilled if fine-tune drifts with IC-LoRA; MSR JSONs default to official filenames)* |
| `models/text_encoders/` | `gemma4_12b_ltx25_uncensored-int8.safetensors` *(or official `gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors`)* | 15.4 GB | All LTX-2.5 workflows (`CLIPLoader`, type `ltxv`) — **do not** use the 26 GB bf16 encoder on a 24 GB 3090 |
| `models/vae/` | `ltx25_uncensored_video_vae.safetensors` *(or official `ltx-2.5-video-vae-bf16.safetensors`)* | 1.5 GB | All LTX-2.5 workflows |
| `models/vae/` | `ltx25_uncensored_audio_vae.safetensors` *(or official `ltx-2.5-audio-vae-bf16.safetensors`)* | 0.4 GB | All LTX-2.5 workflows |
| `models/latent_upscale_models/` | `ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors` | 1.0 GB | DFR, OptionalTwoStage, ManualContinuation, LTXDirector, MSR TwoStage *(must be installed & selected even when Stage 2 is OFF because ComfyUI validates connected loaders)* |
| `models/loras/` | `ltx-2.5-22b-ic-lora-pixel-spatial-upscaler-x2-1.0.safetensors` | ~1–2 GB | **DFR workflow only** (from [`Lightricks/LTX-2.5-22b-IC-LoRA-Pixel-Spatial-Upscaler`](https://huggingface.co/Lightricks/LTX-2.5-22b-IC-LoRA-Pixel-Spatial-Upscaler)) |
| `models/loras/` | `ltx-2.5-22b-ic-lora-refine-details-1.0.safetensors` | ~1–2 GB | **Tiled Fusion 4K Upscale only** (from [`Lightricks/LTX-2.5-22b-IC-LoRA-Refine-Details`](https://huggingface.co/Lightricks/LTX-2.5-22b-IC-LoRA-Refine-Details)) |
| `models/latent_upscale_models/` | `ltx-2.5-latent-temporal-upscaler-x2-bf16-1.0.safetensors` *(optional)* | ~1.0 GB | **DFR Stage 3 (48 fps) only** — OFF by default; placeholder selected so DFR runs without downloading this file until you want 48 fps |
| `models/loras/` | `LTX-2.5-Licon-MSR-V2.safetensors` | 2.2 GB | **MSR workflows only** (`LiconStudio/LTX-2.5-Multiple-Subject-Reference`) |

#### GGUF Quant Choice (distilled, RTX 3090 24 GB)
| File | Size | Notes |
|---|---:|---|
| `Q8_0` | 22.8 GB | Closest to bf16, heavy for 24 GB |
| `Q6_K` | 17.8 GB | **Default** – very good quality |
| `UD-Q5_K_XL` | 16.0 GB | Good compromise |
| `UD-Q4_K_XL` | 14.0 GB | Unsloth's recommendation for tight VRAM |
| `UD-Q3_K_XL` / `UD-Q2_K_XL` | 12 / 9.5 GB | Emergency only |

* Prefer `UD-` variants over plain `Q4_K_M` / `Q3_K_M` at the same size.
* **Skip `nvfp4`** LTX files on the 3090 — Blackwell only (good for the RTX Spark N1X laptop).

### Length (Duration) & Keyframe Positions
LTX-2.5 requires frame counts of **`8n + 1`** (`97`, `121`, `145`, `193`, `241`...). Keep **FPS = 24**.

* **SingleStage / OptionalTwoStage / ManualContinuation / MSR:** Edit **`Duration in seconds`** in Group 2 (`1 + floor(a*b/8)*8`).
* **LTX Director:** Edit **`duration_seconds`** (or drag the timeline end handle) inside **LTX Director**.
* **DFR:** Edit **`duration`** directly on the top-level subgraph node (default `5` s = `121` frames @ 24 fps).

| Duration | Total Frames (`8n+1`) | 3 Images (`MID-A` halfway) | 4 Images (`MID-A` / `MID-B`) | 3090 VRAM Note |
|---:|---:|---:|---:|---|
| **4 s** | 97 | `48` | `32` / `64` | Very fast tests |
| **5 s** | 121 | `60` | `40` / `80` | Fast & safe |
| **6 s** | 145 | `72` | `48` / `96` | Good balance |
| **8 s** | 193 | `96` | `64` / `128` *(or `96` / `144`)* | Default in keyframes workflows |
| **10 s** | 241 | `120` | `80` / `160` | Heavy on 24 GB — lower res or Q5/Q4 if OOM |

> **Important:** Any enabled `frame_idx` must be **strictly less than total frames** (e.g. if you shorten a clip to 4 s / 97 frames, don't leave a guide at `120` or `144`). `END` uses `-1`, which always targets the last frame automatically.

### Resolution Rules & RTX 3090 Presets
Every width and height must be **divisible by 32** (and **divisible by 64** in **LTX Director** so both `1.0×` and `0.5×` stay divisible by 32).

* **SingleStage:** Edit `width` / `height` in Group 2 = **final output size**.
* **OptionalTwoStage / ManualContinuation / MSR TwoStage:** Edit `Stage 1 WIDTH` / `HEIGHT` in Group 2. When `RUN STAGE 2?` = ON, final output = **2×**; when OFF, final output = exact Stage 1 size.
* **LTX Director:** Edit `custom_width` / `custom_height` to your **FINAL target size** (or `0` to match first image); keep `divisible_by = 64`.
* **DFR:** Set `Output size (aspect / megapixels)` (default `16:9` at `0.87 MP` = `1280×704` final; Stage 1 runs at half-res).

| Aspect Ratio | 2-Stage (Stage 1 → Final ×2) | 1-Stage (Direct Final Size) | LTX Director (`custom_width × custom_height`) |
|---|---|---|---|
| **1:1 Square** | `512×512` → **`1024×1024`** *(default)* | `512×512` (draft) or `768×768` | `1024×1024` (2-stage) / `768×768` (1-stage) |
| **16:9 Widescreen** | `768×448` → **`1536×896`** | `768×448` or `832×480` or `960×544` | `1536×896` (2-stage) / `768×448` or `896×512` (1-stage) |
| **16:9 Full HD** | `960×544` → **`1920×1088`** | Avoid 1-stage @ 1080p on 3090 | `1920×1088` (2-stage ON only) |
| **9:16 Vertical** | `448×768` → **`896×1536`** | `448×768` or `544×960` | `896×1536` (2-stage) / `448×768` or `512×896` (1-stage) |

### Using 1, 2, 3, or More Guiding Images
* **`LTX-2.5_I2V_DFR_SingleImage_Audio_GGUF.json`:** Single start image + native audio (enter subgraph → `Switch to T2V` for text-only).
* **`LTX-2.5_I2V_LTXDirector_OptionalTwoStage_GGUF.json` (easiest for 3–5+ images):** Drag images onto the timeline, slide to desired timestamps, right-click final block → **Pin as End Frame**, write a Global Prompt + per-segment prompts (Prompt Relay).
* **`LTX-2.5_I2V_ThreeKeyframes_ManualContinuation_GGUF.json`:** `START` + `MIDDLE (96)` + `END (-1)` are ON by default. For a 4th image (`MID-B`), upload in `EXTRA MID-B image`, adjust indices, and **Ctrl+B** both `MID-B guide` nodes. For standalone clips from a sharp still, set `START preprocess` to `18` and Stage 1 `START` strength to `0.7`.
* **`LTX-2.5_I2V_Keyframes_Dialog_OptionalTwoStage_GGUF.json` / `SingleStage`:** `START` + `END` are ON by default. For **1-image I2V**, press **Ctrl+B** on both `END guide` nodes. To enable `MID-A`/`MID-B`, set the shared frame index and **Ctrl+B** its guide nodes.

### Custom Dialog Audio (Optional) & Multi-Clip Continuation
By default, all LTX-2.5 workflows generate synchronized audio from your prompt.
* **SingleStage & OptionalTwoStage:** Press **Ctrl+B** on the 4 nodes in Group 4c (`LoadAudio`, `Encode dialog`, `mask 0`, `Lock dialog audio`) **plus** `Use dialog audio` in Stage 1. Load a clean WAV matching clip length and state in the prompt who speaks which line.
* **ManualContinuation (long multi-clip dialogue):** Load full recording in `DIALOG`, **Ctrl+B** `Encode dialog` + `mask 0` + `Lock dialog audio` + Stage 1 `Use dialog audio`, flip `CUSTOM VOICE?` ON, and advance `AUDIO START` (`0`, `8`, `16`, …) per clip.
* **LTX Director:** Drag audio onto the Director audio track and set `use_custom_audio = true` (`inpaint_audio = true` generates ambience in gaps; `false` locks the whole track).
* **Multi-clip continuation:** Both `ManualContinuation` and `LTXDirector` automatically save the actual last decoded frame PNG (`last_frame_*.png`) — upload it as the next clip's `START` image.

### MSR Workflows (`LTX/LTX-2.5_MSR_*`)
* **When to use MSR vs Keyframes / LTX Director:** Keyframes/Director anchor *what happens at specific timestamps*; **MSR** locks *character/object/background identity* across angles and cuts using `LTX-2.5-Licon-MSR-V2.safetensors`.
* **Setup:** Clone `ComfyUI-LTX2.5-MSR`, drop `LTX-2.5-Licon-MSR-V2.safetensors` in `models/loras/`, restart ComfyUI, and select your installed model filenames in Group 1 (`ltx25_uncensored_*` or official `ltx-2.5-22b-distilled-*`).
* **Usage:**
  1. Load portraits into `pic1` (required), `pic2`, `pic3`, `pic4`, and optional `background` — references must be **contiguous** (disconnect unused `picN` wires from **both** Stage 1 and Stage 2 MSR guide nodes).
  2. Label them in your prompt as **`Image 1`**, **`Image 2`**, **`Image 3`**… and describe positions/actions.
  3. Always keep `LTXVCropGuides` active before VAE decode.
  4. Start at `832×480` (2-stage → `1664×960`) or `768×448` and `5 s` (`121` frames) on 24 GB.
  5. MSR `audio_ref1/2` are for speaker voice identity (requires an AVref MSR LoRA), *not* full dialogue tracks — use Group 4c (`DIALOG audio`) for lip-syncing a pre-recorded track.

### LTX-2.3 Motion Control (`LTX/LTX-2.3_I2V_ICLoRA_MotionControl_DepthUnion.json`)
* **100% native ComfyUI** (no custom nodes needed) — uses Lightricks' official **LTX-2.3 Union Control IC-LoRA** (`Depth` / `Canny` / `Pose`) with a built-in **MoGe 2** depth extractor subgraph.
* **Separate model set from LTX-2.5:** LTX-2.3 uses its own checkpoint and **Gemma 3** text encoder (do not mix with LTX-2.5 Gemma 4 models):
  * `models/checkpoints/` → [`ltx-2.3-22b-distilled-fp8.safetensors`](https://huggingface.co/Lightricks/LTX-2.3-fp8/resolve/main/ltx-2.3-22b-distilled-fp8.safetensors) (27.5 GB — includes Video & Audio VAEs)
  * `models/text_encoders/` → [`gemma_3_12B_it_fp4_mixed.safetensors`](https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors) (8.8 GB)
  * `models/loras/` → [`ltx-2.3-22b-ic-lora-union-control-ref0.5.safetensors`](https://huggingface.co/Lightricks/LTX-2.3-22b-IC-LoRA-Union-Control/resolve/main/ltx-2.3-22b-ic-lora-union-control-ref0.5.safetensors) (624 MB)
  * `models/loras/` → [`gemma-3-12b-it-abliterated_lora_rank64_bf16.safetensors`](https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/loras/gemma-3-12b-it-abliterated_lora_rank64_bf16.safetensors) (599 MB)
  * `models/geometry_estimation/` → [`moge_2_vitl_normal_fp16.safetensors`](https://huggingface.co/Comfy-Org/MoGe/resolve/main/geometry_estimation/moge_2_vitl_normal_fp16.safetensors) (631 MB)
* **Defaults:** `960×544` @ `24 fps` (safe 3090 start; bump to `1280×704` for finals), `VAEDecodeTiled` (`512, 64, 64, 8`), 5 s clip sliced via `Video Slice`. To use Canny or Pose instead of Depth, swap the MoGe subgraph output for `Canny` (`Detect Edges`) or SDPose frames into `control_images`.

### Recommended Production Routine (ComfyUI + DaVinci Resolve)
1. **Find seed fast:** Run a 1-stage draft (`RUN STAGE 2?` = OFF, `5–8 s`, `512×512` or `768×448`, seed = `randomize`) for 2–4 takes.
2. **Render keeper:** Fix the winning seed and turn `RUN STAGE 2?` = ON (or test hero single-image shots in `DFR`).
3. **Cleanest dialogue audio in DaVinci Resolve:** Feed your original clean WAV into ComfyUI for lip-sync, then align that **same original clean WAV** on the DaVinci Resolve timeline and mute the VAE-decoded MP4 voice track (or blend lightly for LTX ambience), mixing music & SFX separately.
4. **Assemble:** Trim 1–3 frames off continuation joins if needed and do light color/exposure matching across cuts.

---

## 4. MiniMax H3 & Pika H3 Flex (`Minimax/`)

### Ready-to-use workflows (100% native ComfyUI, no custom nodes)
* **[`Minimax/Pika-H3-Flex_Ref2VA_MultiRef_6Step.json`](Minimax/Pika-H3-Flex_Ref2VA_MultiRef_6Step.json)** *(recommended fast Ref2VA, ComfyUI `0.44.0+`)*:
  * Runs Pika's **6-step** distilled Ref2VA adapter (`lcm` + exact 7-value `ManualSigmas`, CFG 1.0) on the **same MiniMax H3 Ref2VA base**.
  * **3 semantic character/scene refs ON** (`<Picture 1..3>`, up to 9 images supported) with `ref_image_size = match`, optional bypassed Start/End `MiniMaxH3AddGuide` timeline pins, optional `<Audio 1>` ref, `LTXVSeparateAVLatent` → `VAEDecodeTiled`, and automatic last-frame PNG save.
  * Defaults to **`960×544` (`0.5 MP`)** / **`5.0 s` (`124` frames)** and scales cleanly up to **`1344×768` (`0.98 MP`)**.
* **[`Minimax/Pika-H3-Flex_Ref2VA_ImagePlusMotionVideo_6Step.json`](Minimax/Pika-H3-Flex_Ref2VA_ImagePlusMotionVideo_6Step.json)** *(easiest **Image + Motion Video** transfer — **0 new models**, ComfyUI `0.44.0+`)*:
  * Wires `LoadVideo` → `Video Slice` → `GetVideoComponents` directly into `MiniMaxH3ReferenceToVideo.ref_video_0` (`<Video 1>`) alongside your character/scene image(s) (`<Picture 1>`, optional `<Picture 2>`), plus an optional bypassed frame-0 START pin.
  * Transfers body movement, gesture timing, and camera choreography in **6 steps** without needing a ControlNet or pose extractor. Convert non-24fps source videos to **24 fps** if timing drifts.
* **[`Minimax/MiniMax-H3_FunControlNet_PosePlusImage.json`](Minimax/MiniMax-H3_FunControlNet_PosePlusImage.json)** *(exact **limb-for-limb Pose ControlNet + Character Image**, ComfyUI `0.35.0+`)*:
  * Adapted from ComfyUI's official `video_minimax_h3_fun_controlnet_union` template with `<Picture 1>` wired into `ref_image_0`, built-in **SDPose wholebody skeleton extractor**, **`LTXVSeparateAVLatent` → `VAEDecodeTiled`** for 3090 safety, and 4-step Turbo ON by default (toggle OFF for 20-step base). Use when `<Video 1>` alone is too loose for strict dance/choreography.
* **[`Minimax/Pika-H3-Flex_FL2VA_FirstLast_6Step.json`](Minimax/Pika-H3-Flex_FL2VA_FirstLast_6Step.json)** *(ComfyUI `0.44.0+`)*:
  * **6-step** First & Last Frame (or **1-image Start-Only I2V** by disconnecting `last_frame` on `MiniMaxH3ImageToVideo`) with native stereo audio, tiled VAE decode, and last-frame PNG save.
  * Uses the separate **FL2VA base + FL2VA Pika LoRA** (shares the same Qwen3-VL text encoder and Video/Audio VAEs).
* **[`Minimax/MiniMax-H3_Ref2VA_MultiChar_4StepTurbo.json`](Minimax/MiniMax-H3_Ref2VA_MultiChar_4StepTurbo.json)** *(ComfyUI `0.34.0+`)*:
  * **4-step Ref2V Turbo LoRA ON** (`4-STEP TURBO?` toggle switches between 4-step fastest drafts and **20-step base**).
  * Keep at `0.4–0.5 MP` (`864×480`–`960×544`) while 4-step Turbo is ON (trained at 544p).

> **Image + Motion from a Reference Video — Why MiniMax / Pika H3?**
> * **MiniMax / Pika H3 (`Minimax/`):** Best native support — direct `<Video 1>` motion reference in 6 steps (**0 extra models**) OR exact SDPose/Depth/Canny **Fun ControlNet Union**.
> * **LTX (`LTX/`):** Lightricks has not released a general RGB Pose/Depth/Canny Union IC-LoRA for **LTX-2.5** yet (`Layout-To-Render` is for 3D clay playblasts), so use **[`LTX/LTX-2.3_I2V_ICLoRA_MotionControl_DepthUnion.json`](LTX/LTX-2.3_I2V_ICLoRA_MotionControl_DepthUnion.json)** if you specifically want LTX motion control via Depth/Canny/Pose.
> * **HunyuanVideo 1.5 (`HunyuanVideo1.5/`):** No native ComfyUI motion-transfer or pose ControlNet workflow (T2V / 1-image I2V / 1080p SR only).

> **Critical Pika H3 Flex rules:** Never mix Ref2VA and FL2VA models/LoRAs, never stack a Turbo/Lightning LoRA on top of Pika H3 Flex, and keep LoRA strength `1.0`, sampler `lcm`, and all 7 `ManualSigmas` values unchanged (raising steps to 8 does not add detail and breaks the trained schedule).

### Model Files (`Comfy-Org/MiniMax-H3` & `Comfy-Org/SDPose`)

| Folder | File | Approx. Size | Used By |
|---|---|---:|---|
| `models/text_encoders/` | [`qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors) | 15.7 GB | **All 5 workflows** *(works on 3090 via emulation to save RAM; INT8 alternative exists if you want to compare)* |
| `models/vae/` | [`minimax_h3_video_vae_int8_convrot.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/vae/minimax_h3_video_vae_int8_convrot.safetensors) | 2.8 GB | **All 5 workflows** |
| `models/vae/` | [`minimax_h3_audio_vae_fp32.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/vae/minimax_h3_audio_vae_fp32.safetensors) | 0.6 GB | **All 5 workflows** |
| `models/diffusion_models/` | [`minimax_h3_ref2va_pruned_int8_convrot.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors) | 21.0 GB | Pika Ref2VA, Pika MotionVideo, FunControlNet Pose, MiniMax 4-Step Ref2VA |
| `models/loras/` | [`pika_h3_flex_ref2va_v1_bf16.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/loras/pika_h3_flex_ref2va_v1_bf16.safetensors) | ~2 GB | **Pika Ref2VA + Pika Image+MotionVideo (6-step)** |
| `models/loras/` | [`minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors) | 2.0 GB | **MiniMax Ref2VA (4-step Turbo) + FunControlNet Pose** |
| `models/diffusion_models/` | [`minimax_h3_fl2va_pruned_int8_convrot.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors) | 19.5 GB | **Pika FL2VA (First & Last Frame)** |
| `models/loras/` | [`pika_h3_flex_fl2va_v1_bf16.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/loras/pika_h3_flex_fl2va_v1_bf16.safetensors) | ~2 GB | **Pika FL2VA (6-step)** |
| `models/model_patches/` | [`minimax_h3_fun_controlnet_union_pruned_int8_convrot.safetensors`](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/model_patches/minimax_h3_fun_controlnet_union_pruned_int8_convrot.safetensors) | 2.1 GB | **FunControlNet Pose+Image only** (also supports Canny / Depth / Inpaint) |
| `models/checkpoints/` | [`sdpose_wholebody_fp16.safetensors`](https://huggingface.co/Comfy-Org/SDPose/blob/main/checkpoints/sdpose_wholebody_fp16.safetensors) | 1.8 GB | **FunControlNet Pose+Image only** (SDPose skeleton extractor) |
| `models/diffusion_models/` | [`rt_detr_v4-x-hgnet_fp16.safetensors`](https://huggingface.co/Comfy-Org/SDPose/blob/main/diffusion_models/rt_detr_v4-x-hgnet_fp16.safetensors) | 118 MB | **FunControlNet Pose+Image only** (SDPose person detector) |

### RTX 3090 Notes for MiniMax H3 / Pika H3 Flex
* **ComfyUI & CUDA:** Use ComfyUI **`0.44.0+`**. INT8 ConvRot benefits from PyTorch **CUDA 13.0+**. Check with your ComfyUI Python:
  ```bash
  python -c "import torch; print('PyTorch:', torch.__version__, 'CUDA build:', torch.version.cuda, 'GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'unavailable')"
  ```
* **Frame cadence:** H3 snaps duration to `17n + 5` (`5 s` → `124` frames ≈ `5.17 s` @ 24 fps).
* **Prompting:** Tag references as `<Picture 1>`, `<Picture 2>`, `<Picture 3>`, and dialogue as `(S1) ... <d>[English] Hello there.</d>` (see [MiniMax H3 Prompt Guide](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide)).
* **Guides vs semantic refs:** An image wired only to `MiniMaxH3AddGuide` is not automatically visible as `<Picture N>` — connect it to `ref_images` too if referenced by tag in the prompt.
* **Memory & speed:** Model weights offload between 24 GB VRAM and 64 GB system RAM. Draft at `0.4–0.5 MP` / `5 s` first (`~1.5–3 min` typical on a 3090 at 4–6 steps), then raise Pika H3 Flex to `0.98 MP` (`1344×768`) for finals. If you hit RAM pressure on a smaller machine, `--disable-pinned-memory` can help.

---

## 5. Wan 2.2 14B (`WAN/`) & HunyuanVideo 1.5 (`HunyuanVideo1.5/`)

All 3 workflows use **100% native ComfyUI core nodes** (no custom nodes required) and save a `last_frame` PNG alongside each MP4.

### Wan 2.2 14B First-Last Frame (`WAN/`)
* **[`WAN/Wan2.2_14B_I2V_FLF_4StepLightX2V.json`](WAN/Wan2.2_14B_I2V_FLF_4StepLightX2V.json)** — fast **4-step** preset (2 High-Noise + 2 Low-Noise, CFG `1.0`, shift `5.0`, `832×480`, `5 s` = `81` frames @ 16 fps).
* **[`WAN/Wan2.2_14B_I2V_FLF_8StepOrBase20Step.json`](WAN/Wan2.2_14B_I2V_FLF_8StepOrBase20Step.json)** — 1-click **`USE 8-STEP LORA?`** toggle:
  * **ON (default):** **8 steps** (4 High + 4 Low, CFG `1.0`, shift `5.0`) — cleaner hands/motion than 4 steps while still fast.
  * **OFF:** **20-step Base** (10 High + 10 Low, CFG `3.5`, shift `8.0`, no LoRA) for maximum motion dynamics.
* **1-Image I2V only:** Disconnect `end_image` on `WanFirstLastFrameToVideo`.

**Wan 2.2 14B Model Files** ([`Comfy-Org/Wan_2.2_ComfyUI_Repackaged`](https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged) & [`Wan_2.1_ComfyUI_repackaged`](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged)):
| Folder | File |
|---|---|
| `models/diffusion_models/` | `wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors` |
| `models/diffusion_models/` | `wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors` |
| `models/loras/` | `wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors` |
| `models/loras/` | `wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors` |
| `models/text_encoders/` | `umt5_xxl_fp8_e4m3fn_scaled.safetensors` |
| `models/vae/` | `wan_2.1_vae.safetensors` |

### HunyuanVideo 1.5 I2V (`HunyuanVideo1.5/`)
* **[`HunyuanVideo1.5/HunyuanVideo-1.5_I2V_FastDistilled.json`](HunyuanVideo1.5/HunyuanVideo-1.5_I2V_FastDistilled.json)** — pre-configured for `hunyuanvideo1.5_480p_i2v_step_distilled_fp16.safetensors` loaded with `weight_dtype = fp8_e4m3fn` (~9 GB VRAM), **12 steps** (8–12 rec.), CFG `1.0`, shift `7.0`, `848×480`, `5 s` (`121` frames @ 24 fps).
* **720p Base option:** Swap Node 1 to `hunyuanvideo1.5_720p_i2v_fp16.safetensors`, set `1280×720`, CFG `6.0`, `20–50` steps, shift `7.0`.

**HunyuanVideo 1.5 Model Files** ([`Comfy-Org/HunyuanVideo_1.5_repackaged`](https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged) & [`Comfy-Org/sigclip_vision_384`](https://huggingface.co/Comfy-Org/sigclip_vision_384)):
| Folder | File |
|---|---|
| `models/diffusion_models/` | `hunyuanvideo1.5_480p_i2v_step_distilled_fp16.safetensors` *(or optional `720p_i2v_fp16`)* |
| `models/text_encoders/` | `qwen_2.5_vl_7b_fp8_scaled.safetensors` |
| `models/text_encoders/` | `byt5_small_glyphxl_fp16.safetensors` |
| `models/clip_vision/` | `sigclip_vision_patch14_384.safetensors` |
| `models/vae/` | `hunyuanvideo15_vae_fp16.safetensors` |

### Adding Audio to Wan 2.2 / HunyuanVideo 1.5
1. **Direct mux inside the workflow:** Press **Ctrl+B** on the bypassed `LoadAudio` + `TrimAudioDuration` nodes wired into `CreateVideo` to trim and mux WAV/MP3 straight into the MP4.
2. **AI-generated SFX/Foley (`ComfyUI-MMAudio`):** Install [`kijai/ComfyUI-MMAudio`](https://github.com/kijai/ComfyUI-MMAudio) (~4–6 GB VRAM) to generate matching footsteps/ambience/Foley directly from video frames.
3. **DaVinci Resolve / Talking shots:** Mix music/SFX in Resolve; for **speaking lip-sync shots**, render that shot in **LTX-2.5** (locks your voice WAV) or **MiniMax / Pika H3 Flex**.

---

## 6. Audio Generation (`Audio/`)

### A. Voice Cloning & Dialogue TTS ([`Audio/Audio_Qwen3TTS_VoiceClone_TTSSuite.json`](Audio/Audio_Qwen3TTS_VoiceClone_TTSSuite.json))
* **Custom node required:** [`diodiogod/TTS-Audio-Suite`](https://github.com/diodiogod/TTS-Audio-Suite)
  ```bash
  cd ComfyUI/custom_nodes
  git clone https://github.com/diodiogod/TTS-Audio-Suite
  pip install -r TTS-Audio-Suite/requirements.txt
  ```
* **Auto-downloads model:** **Qwen3-TTS Base 1.7B** (Apache 2.0, ~4–6 GB VRAM, 10 languages).
* **Clone an existing voice:** Load a **3–15 s** clean speech clip in `LoadAudio`, paste its **exact spoken words** into `CharacterVoicesNode`, type your script in `PrimitiveStringMultiline` (supports `[pause:0.8s]` and `[Character]` tags), and Queue.
* **Invent a brand-new character voice from text, then lock it:**
  1. Switch `Qwen3-TTS Engine` to **`TTS - VoiceDesign 1.7B`** (or `TTS - CustomVoice 1.7B` for 9 presets), disconnect `opt_narrator` on `UnifiedTTSTextNode`, describe the voice, generate a clean 5–10 s sentence, and save it.
  2. Switch back to **`TTS - Base 1.7B (Voice Clone)`**, reconnect `opt_narrator`, load that saved clip into `LoadAudio`, and paste its exact sentence into `CharacterVoicesNode` — now every line stays locked to that voice.
* **Extras included:** Un-bypass **`ChatterBoxEngineNode`** (`Ctrl+B`) for 23-language cloning without a transcript; `TTS-Audio-Suite` also supports **RVC voice conversion**.

### B. Text-to-Music & Background Scores ([`Audio/Audio_ACEStep15_TextToMusic.json`](Audio/Audio_ACEStep15_TextToMusic.json))
* **100% native ComfyUI** — runs in **under 10 seconds on an RTX 3090** (<4 GB VRAM).
* **Single model file:** Download [`ace_step_1.5_turbo_aio.safetensors`](https://huggingface.co/Comfy-Org/ace_step_1.5_ComfyUI_files/resolve/main/checkpoints/ace_step_1.5_turbo_aio.safetensors) (~9.3 GB, MIT license) into `ComfyUI/models/checkpoints/`.
* Set `Duration in seconds` (default `30 s`, up to `600 s`). Use `[Instrumental]` in `lyrics` for film scores, or `[Verse 1]` / `[Chorus]` for vocal songs.

---

## 7. Upscaling Beyond 1080p (Optional)

| Method | Quality | Speed | Notes |
|---|---|---|---|
| [`LTX/LTX-2.5_V2V_TiledFusion_4K_Upscale_GGUF.json`](LTX/LTX-2.5_V2V_TiledFusion_4K_Upscale_GGUF.json) | Best LTX-native | Slow | FullHD/4K/8K, adapted from Lightricks `ComfyUI-LTXVideo` for your GGUF setup (needs `ltx-2.5-22b-ic-lora-refine-details-1.0.safetensors`; use `tile_size = qHD` if `HD` hits VRAM limit at 4K) |
| SeedVR2 | Very good, temporally consistent | Slow | Use block swap on 3090, process in frame batches |
| `Upscale Image (using Model)` + 4x-UltraSharp / RealESRGAN | OK | Fast | Per-frame → slight flicker |
| RIFE / FILM (`ComfyUI-Frame-Interpolation`) | – | Fast | 24 → 48 fps for smoother motion (or use DFR Stage 3) |

Save with native `SaveVideo` or VHS Video Combine (H.264/H.265, CRF 16–18).

---

## 8. Linux RTX 3090 Installation, Troubleshooting & Tips

### Installation (Linux, RTX 3090)
ComfyUI Desktop is officially Windows/macOS only — on Linux use the git install:
```bash
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI
python -m venv venv && source venv/bin/activate
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
pip install -r requirements.txt
pip install -r manager_requirements.txt
pip install triton sageattention   # or compile SageAttention 2.2 for CUDA 13: see Compile-sage-linux.md

cd custom_nodes
git clone https://github.com/city96/ComfyUI-GGUF && pip install -r ComfyUI-GGUF/requirements.txt
git clone https://github.com/liconstudio/ComfyUI-LTX2.5-MSR          # MSR workflows only
git clone https://github.com/WhatDreamsCost/WhatDreamsCost-ComfyUI   # LTX Director only
git clone https://github.com/diodiogod/TTS-Audio-Suite && pip install -r TTS-Audio-Suite/requirements.txt  # Qwen3-TTS only
# optional/useful:
git clone https://github.com/Lightricks/ComfyUI-LTXVideo
git clone https://github.com/kijai/ComfyUI-KJNodes
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite
git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation
```

Launch (see [`start-comfy.sh`](start-comfy.sh)):
```bash
python main.py --use-sage-attention --enable-manager
# add --listen 0.0.0.0 for LAN access, or --reserve-vram 1 if the monitor uses the 3090
```
* Do **not** use `--highvram`. Use `--lowvram` only as a last resort.
* `--fast` gives nothing on the 3090 (FP8 speedups need Ada/Blackwell).

### Out-of-Memory / Slow Checklist (RTX 3090 24 GB)
1. Lower `VAEDecodeTiled` `tile_size`: `512` → `384` → `256`.
2. In LTX Director, set `use_tiled_encode = true` on both `LTXDirectorGuide` nodes.
3. Reduce resolution (`1024×1024` → `768×768`, `960×544` → `768×448`) or duration (`10 s` → `8 s` → `5 s`).
4. Try a smaller GGUF (`UD-Q5_K_XL` or `UD-Q4_K_XL` instead of `Q6_K`).
5. MSR / MiniMax Ref2VA: fewer reference images.
6. Close GPU-accelerated browser tabs; add `--reserve-vram 1`.
7. Watch the console: **"loaded partially"** = model didn't fit in VRAM → slow (fix with steps 3–5). 64 GB system RAM is recommended for offloaded parts.

### ComfyUI Manager Notes
* ComfyUI Desktop already includes the Manager — don't clone `ComfyUI-Manager` into `custom_nodes` too.
* `"not allowed with this security level"`: edit `user/default/ComfyUI-Manager/config.ini` (or `user/__manager/config.ini`) → `security_level = normal` (or `weak` for git URL installs).
* Git install: run with `--enable-manager`.

### Coming from Wan2GP – What Replaces What
| Wan2GP | ComfyUI |
|---|---|
| mmgp offloading / profiles | ComfyUI smart memory, Kijai WanVideoWrapper block swap, ComfyUI-MultiGPU DisTorch |
| int8/fp8 quantization | fp8 scaled / int8 ConvRot checkpoints, GGUF via `ComfyUI-GGUF` |
| Sage attention | `--use-sage-attention` |
| TeaCache | TeaCache / MagCache nodes (KJNodes, WanVideoWrapper) |
| Distilled LoRAs (LightX2V, CausVid) | Same LoRAs, 4–8 steps, CFG 1 |
| VAE tiling | `VAEDecodeTiled` |
| compile | TorchCompile nodes (needs Triton) |

---

## 9. Other Local Video Models Comparison (Reference)

| Model | Images & timeline control | Audio | Practical on a 3090 |
|---|---|---|---|
| [LTX-2.5](https://docs.comfy.org/tutorials/video/ltx/ltx-2-5) | Start/Mid/End guides, DFR single-image, LTX Director timeline, MSR multi-subject refs, continuation last-frame. | Generates synchronized audio + locks prerecorded dialogue for lip-sync. | Primary daily driver with GGUF Q6_K + int8 Gemma 4. |
| [MiniMax H3 / Pika H3 Flex](https://docs.comfy.org/tutorials/video/pika/pika-h3-flex) | Ref2VA (up to 9 images + guides) and FL2VA (first/last frame). | Native stereo speech, music, and SFX; `<Audio 1>` timbre ref. | Pruned INT8 + dynamic offloading works on 24 GB + 64 GB RAM; 4–6 steps takes ~1.5–3 min. |
| [Kandinsky 6 Lite / Lite Distill](https://github.com/kandinskylab/kandinsky-6/tree/main/comfyui) | 1 image in ComfyUI example (FLF in Python pipeline); 5 s clips. | Native synced audio; audio-to-video mode cannot combine with image input. | 3B Lite / 10-step distill is lighter, though full pipeline still uses encoders/VAEs/vocoder. |
| [LongCat Video / Avatar 1.6](https://github.com/meituan-longcat/LongCat-Video) | I2V & continuation; Avatar focuses on talking characters rather than timed keyframes. | **Audio-driven:** animates a character from speech. | 13.6B model; needs quantized/offloaded setup. |
| [HunyuanVideo 1.5](https://docs.comfy.org/tutorials/video/hunyuan/hunyuan-video-1-5) | T2V and 1-image I2V. | Video only; mux audio or use MMAudio. | Very light (~9 GB VRAM in FP8 distilled). Regional license restrictions apply. |
| [FramePack](https://github.com/lllyasviel/FramePack) | Starts from 1 image and progressively generates longer video. | No native soundtrack. | Runs from 6 GB VRAM, slower on long clips. |
| [SkyReels V2 1.3B](https://github.com/SkyworkAI/SkyReels-V2) | I2V or Diffusion Forcing start/end continuation. | No native soundtrack. | ~14.7 GB peak VRAM at 540p. |

---

## 10. RTX Spark N1X Laptop vs. RTX 3090

* **Best split between the two machines:** Generate high-res **images on the RTX Spark N1X** (128 GB unified memory, native Blackwell FP8/NVFP4) → render **videos on the RTX 3090** (~936 GB/s VRAM bandwidth vs ~273–300 GB/s unified memory bandwidth on N1X). You can share a folder or run the 3090 with `--listen 0.0.0.0` on a trusted LAN.
* **For images on RTX Spark N1X (128 GB):**
  * Turn off memory tricks: no block swap, no `--lowvram`/`--reserve-vram`, no small GGUF just to fit, no tiled VAE needed.
  * Prefer **FP8 / NVFP4** models (`--fast` helps on Blackwell) and turbo/lightning/distilled models (fewer steps = biggest speedup).
  * Leave ~16–20 GB for Windows + apps; plug in and use **Performance** power mode.
  * **Windows on ARM caveats:** Needs native ARM64 + CUDA PyTorch; SageAttention / Triton / TorchCompile / compiled x86 wheels (e.g. InsightFace) may not exist yet — PyTorch SDPA attention and pure-Python nodes work fine.
* **Can RTX Spark N1X run MiniMax H3 locally?** Yes on the **128 GB** configuration (note: a smaller 32 GB N1X exists — check installed RAM; N1X is not the same product as DGX Spark GB10). More memory avoids 3090-to-RAM offloading, **but** lower memory bandwidth means per-step sampling is typically slower than a stock 3090 (one comparison reported ~15.06 s/step vs ~8.20 s/step at 832×480 I2V).
