# LTX-2.5 Image-to-Video Workflows Guide (ComfyUI – RTX 3090)

Complete guide for the **4 workflows in `new/`** plus the **MSR multi-reference workflows** in the parent `comfyui-workflows/` folder. Every workflow also includes a built-in **`HOW TO: Length, Resolution & 3+ Images`** note panel directly inside ComfyUI.

---

## 1. Which Workflow Should You Use?

| Workflow (in `new/`) | Best For | Stages | Default Images Enabled | Custom Audio |
|---|---|---|---|---|
| `LTX-2.5_I2V_LTXDirector_OptionalTwoStage_GGUF.json` | **Visual timeline** with **3, 4, or more images**, different prompts per time segment (Prompt Relay), drag-and-drop audio, and automatic last-frame PNG save | **1-stage or 2-stage** (`RUN STAGE 2?` toggle) | Drag & drop as many as you want | Built into Director (`use_custom_audio`) |
| `LTX-2.5_I2V_ThreeKeyframes_ManualContinuation_GGUF.json` | **Ready-to-run 3-image** workflow (`START` + `MIDDLE` + `END`, optional 4th `MID-B`), saves last decoded frame PNG for manual multi-clip continuation | **1-stage or 2-stage** (`RUN STAGE 2?` toggle) | **3 ON** (`START`, `MIDDLE @ 96`, `END @ -1`); `MID-B @ 144` bypassed | Optional full-track audio + `TrimAudioDuration` (`AUDIO START`) |
| `LTX-2.5_I2V_Keyframes_Dialog_OptionalTwoStage_GGUF.json` | Clean general-purpose **2–4 image** keyframe workflow with fast 1-stage draft or 2-stage final toggle | **1-stage or 2-stage** (`RUN STAGE 2?` toggle) | **2 ON** (`START`, `END`); `MID-A` & `MID-B` bypassed | Optional dialog audio (auto-fitted & locked) |
| `LTX-2.5_I2V_Keyframes_Dialog_SingleStage_GGUF.json` | Pure **1-stage only** (no spatial upscaler model needed at all), up to 4 images | **1-stage only** | **2 ON** (`START`, `END`); `MID-A` & `MID-B` bypassed | Optional dialog audio (auto-fitted & locked) |

> **Is 2-stage mandatory?** **No.** 1-stage works great for fast renders and moderate resolutions (up to ~`768×768` or `960×544`). Use **2-stage** when you want `1024×1024` or `1080p` (`1920×1088`) on a 24 GB RTX 3090 — generating motion at low resolution and refining at ×2 is sharper, more stable, and safer on VRAM.

---

## 2. Required Models & Custom Nodes

### Custom Nodes (`ComfyUI/custom_nodes/`)
* **All 4 workflows:** [`ComfyUI-GGUF`](https://github.com/city96/ComfyUI-GGUF) (`UnetLoaderGGUF`)
* **LTX Director workflow only:** [`WhatDreamsCost-ComfyUI`](https://github.com/WhatDreamsCost/WhatDreamsCost-ComfyUI) (latest v2.0+ with `LTXDirector`, `LTXDirectorGuide`, `LTXDirectorCropGuides`) + up-to-date ComfyUI & [`ComfyUI-LTXVideo`](https://github.com/Lightricks/ComfyUI-LTXVideo)
* **MSR workflows (parent folder) only:** [`ComfyUI-LTX2.5-MSR`](https://github.com/liconstudio/ComfyUI-LTX2.5-MSR)

### Model Files (pre-selected in `new/` workflows)
| ComfyUI Folder | File | Used By |
|---|---|---|
| `models/unet/` | `ltx25_uncensored_v1.1-Q6_K.gguf` (or official `ltx-2.5-22b-distilled-Q6_K.gguf`) | All workflows |
| `models/text_encoders/` | `gemma4_12b_ltx25_uncensored-int8.safetensors` | All workflows (`CLIPLoader`, type `ltxv`) |
| `models/vae/` | `ltx25_uncensored_video_vae.safetensors` | All workflows |
| `models/vae/` | `ltx25_uncensored_audio_vae.safetensors` | All workflows |
| `models/latent_upscale_models/` | `ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors` | OptionalTwoStage, ManualContinuation, LTXDirector *(must be installed & selected even when Stage 2 is OFF because ComfyUI validates connected loaders)* |
| `models/loras/` | `LTX-2.5-Licon-MSR-V2.safetensors` | Parent-folder MSR workflows only |

---

## 3. How to Change Length (Duration) & Keyframe Positions

LTX-2.5 requires frame counts of **`8n + 1`** (`97`, `121`, `145`, `193`, `241`...). Keep **FPS = 24**.

### Where to change duration
* **SingleStage / OptionalTwoStage / ManualContinuation:** Edit **`Duration in seconds`** (or `Clip duration in seconds`) in **Group 2**. The math node (`1 + floor(a*b/8)*8`) automatically calculates a valid `8n + 1` frame count.
* **LTX Director:** Edit **`duration_seconds`** (or drag the timeline end handle) directly inside the **LTX Director** node. Director automatically snaps to `8n + 1`.

### Length & Keyframe Lookup Table (@ 24 fps)

| Duration | Total Frames (`8n+1`) | 3 Images (`MID-A` halfway) | 4 Images (`MID-A` / `MID-B`) | 3090 VRAM Note |
|---:|---:|---:|---:|---|
| **4 s** | 97 | `48` | `32` / `64` | Very fast tests |
| **5 s** | 121 | `60` | `40` / `80` | Fast & safe |
| **6 s** | 145 | `72` | `48` / `96` | Good balance |
| **8 s** | 193 | `96` | `64` / `128` *(or `96` / `144`)* | Default in `new/` |
| **10 s** | 241 | `120` | `80` / `160` | Heavy on 24 GB — use lower res or Q5/Q4 if OOM |

> **Important:** Any enabled `frame_idx` must be **strictly less than total frames** (e.g. if you shorten a clip to 4 s / 97 frames, don't leave a guide at `120` or `144` or `LTXVAddGuide` will error). `END` uses `-1`, which always targets the last frame automatically.

---

## 4. How to Change Resolution

Every width and height must be **divisible by 32** (and **divisible by 64** in **LTX Director** so both `1.0×` and `0.5×` stay divisible by 32).

### Where to change resolution
* **SingleStage (`...SingleStage_GGUF.json`):** Edit **`width`** and **`height`** in **Group 2**. This is your **final output resolution**.
* **OptionalTwoStage & ManualContinuation:** Edit **`Stage 1 WIDTH`** and **`Stage 1 HEIGHT`** in **Group 2**.
  * When **`RUN STAGE 2?` = ON:** Final output is **2× WIDTH × 2× HEIGHT** (e.g. `512×512` → `1024×1024`, `768×448` → `1536×896`).
  * When **`RUN STAGE 2?` = OFF:** Final output is **exact WIDTH × HEIGHT** (so for 1-stage final output, set `768×768` or `768×448` directly).
* **LTX Director (`...LTXDirector_OptionalTwoStage_GGUF.json`):** Edit **`custom_width`** and **`custom_height`** inside the **LTX Director** node to your **FINAL target size** (or set both to `0` to match your first image). Keep **`divisible_by = 64`**.
  * When **`RUN STAGE 2?` = ON:** Stage 1 automatically downscales to `0.5×` (`scale_by = 0.5`), then Stage 2 refines ×2 back to your `custom_width × custom_height`.
  * When **`RUN STAGE 2?` = OFF:** Stage 1 automatically runs at `1.0×` (`scale_by = 1.0`) and skips Stage 2.

### Recommended RTX 3090 (24 GB) Resolution Presets

| Aspect Ratio | 2-Stage (Stage 1 → Final ×2) | 1-Stage (Direct Final Size) | LTX Director (`custom_width × custom_height`) |
|---|---|---|---|
| **1:1 Square** | `512×512` → **`1024×1024`** *(default)* | `512×512` (draft) or `768×768` | `1024×1024` (2-stage) / `768×768` (1-stage) |
| **16:9 Widescreen** | `768×448` → **`1536×896`** | `768×448` or `832×480` or `960×544` | `1536×896` (2-stage) / `768×448` or `896×512` (1-stage) |
| **16:9 Full HD** | `960×544` → **`1920×1088`** | Avoid 1-stage @ 1080p on 3090 | `1920×1088` (2-stage ON only) |
| **9:16 Vertical** | `448×768` → **`896×1536`** | `448×768` or `544×960` | `896×1536` (2-stage) / `448×768` or `512×896` (1-stage) |

> Match your input images' aspect ratio to your chosen resolution to avoid unwanted cropping or distortion.

---

## 5. How to Use 3 or More Guiding Images

### A. In `LTX-2.5_I2V_LTXDirector_OptionalTwoStage_GGUF.json` (Easiest for 3, 4, 5+ images)
1. Drag and drop your images directly onto the **LTX Director** timeline track.
2. Slide each image block to where you want it to appear on the timeline (e.g. `0s`, `2.5s`, `5.5s`, `8s`).
3. Right-click the final image block → **Pin as End Frame** so it lands on the exact last frame.
4. Write a **Global Prompt** (characters, setting, lighting) and a **per-segment prompt** for each block — Prompt Relay automatically scopes each prompt to its segment.

### B. In `LTX-2.5_I2V_ThreeKeyframes_ManualContinuation_GGUF.json`
* **3 images are already ON by default:** `1. START`, `2. MIDDLE` (frame `96`), and `3. END` (frame `-1`). Just upload your 3 images and run.
* **To add a 4th image (`MID-B`):**
  1. Upload your image in `EXTRA MID-B image`.
  2. Set `MIDDLE` (e.g. `64`) and `MID-B` (e.g. `128`, or keep `96` and `144`).
  3. Select **both** `MID-B guide - STAGE 1` and `MID-B guide - STAGE 2` → press **Ctrl+B** to un-bypass.
* **To remove END or MIDDLE:** Select **both** its Stage 1 & Stage 2 guide nodes → press **Ctrl+B**.
* **Tip for standalone clips:** `START` defaults to `img_compression = 0` and `strength = 1.0` for clip-to-clip stitching. If starting from a sharp still image and motion feels stiff, set `START preprocess` to `18` and Stage 1 `START` strength to `0.7`.

### C. In `LTX-2.5_I2V_Keyframes_Dialog_OptionalTwoStage_GGUF.json`
* `START` and `END` are ON by default.
* To enable **MID-A** (3rd image) and/or **MID-B** (4th image): load the image, set its shared `frame index` primitive below the image, then select **both** its Stage 1 & Stage 2 guide nodes → press **Ctrl+B**.

### D. In `LTX-2.5_I2V_Keyframes_Dialog_SingleStage_GGUF.json`
* `START` and `END` are ON by default.
* To enable **MID-A** or **MID-B**: select its LoadImage + preprocess + single guide node → press **Ctrl+B**, choose your image, and set `frame_idx` on the guide node.

---

## 6. How to Use Custom Dialog Audio (Optional)

By default, **all 4 workflows generate synchronized LTX-2.5 audio automatically** from your prompt.

* **In SingleStage & OptionalTwoStage:**
  1. Select the 4 nodes in Group 4c (`LoadAudio`, `Encode dialog`, `mask 0`, `Lock dialog audio`) **plus** `Use dialog audio` in Stage 1 → press **Ctrl+B** to enable them.
  2. Choose your audio file (match the clip length; ComfyUI automatically trims/pads to exact frame length and locks the voice with mask `0`).
  3. State in the prompt who speaks which line so LTX lip-syncs the right character.
* **In ManualContinuation (for long multi-clip dialogue):**
  1. Load your full voice recording in `DIALOG` (keep `LoadAudio` and `Trim voice` active).
  2. Select `Encode dialog`, `mask 0`, `Lock dialog audio`, and Stage 1 `Use dialog audio` → press **Ctrl+B**.
  3. Flip **`CUSTOM VOICE?`** to **ON**.
  4. Set **`AUDIO START`** to `0` for clip 1, `8` for clip 2, `16` for clip 3, etc. (`Clip duration` trims each slice automatically, and nested-AV concatenation auto-fits the 8.0s slice to the 193-frame ≈ 8.04s latent).
* **In LTX Director:**
  1. Drag your audio file directly onto the **audio track** inside the **LTX Director** node and trim/position it visually.
  2. Turn **`use_custom_audio = true`** inside Director. Leave **`inpaint_audio = true`** to let LTX generate sound/ambience in empty gaps, or turn it `false` to lock the entire audio track.

---

## 7. Multi-Clip Continuation (Making Longer Videos)

Both **`ManualContinuation`** and **`LTXDirector`** automatically extract the actual last decoded frame (`ImageFromBatch` index `-1`) and save it as a PNG alongside your MP4:
* `ManualContinuation` → `ComfyUI/output/LTX25_Manual_Continuation/last_frame_*.png`
* `LTXDirector` → `ComfyUI/output/video/LTX25_Director_last_frame_*.png`

For the next clip: upload that `last_frame` PNG as the new **START** image (or drop it at `0s` in LTX Director), load new middle/end images, update the prompt (and `AUDIO START` if using custom dialogue), and render the next clip. Assemble clips in your video editor.

---

## 8. Recommended Production & Testing Guideline (ComfyUI + DaVinci Resolve)

Follow this step-by-step routine when testing a scene and building a full AI video:

### Step 1 — First Test Shot (validate your setup)
1. Prepare **3 consistent still images** (start, middle, end) with the same characters, lighting, and aspect ratio.
2. Start with **`LTX-2.5_I2V_LTXDirector_OptionalTwoStage_GGUF.json`** (for visual timeline + per-segment prompts) or **`LTX-2.5_I2V_ThreeKeyframes_ManualContinuation_GGUF.json`** (3 keyframes already wired).
3. Run a **fast draft first**:
   * Set **`RUN STAGE 2?` = OFF** (1-stage).
   * Use **5 s** (`121` frames) or **8 s** (`193` frames) at **24 fps** and a modest size (`512×512`, `768×768`, or `768×448`).
   * Keep the Stage 1 seed on **`randomize`** and roll **2–4 takes** until motion, framing, and faces look natural.
4. **Render the keeper at final resolution:**
   * Switch Stage 1 seed to **`fixed`** on the best take.
   * Turn **`RUN STAGE 2?` = ON** (e.g. `512×512` → `1024×1024`, or `768×448` → `1536×896` / `960×544` → `1920×1088`).
   * Compare motion, face stability, and lip-sync against the 1-stage draft before rendering the rest of your shots.

### Step 2 — Swapping Audio & Best-Practice Audio Workflow
* **Option A (LTX generates sound):** Leave custom audio OFF — LTX-2.5 generates synchronized voices, ambience, and SFX from your prompt.
* **Option B (Your own voice/dialogue for lip-sync):** Load your clean WAV into the workflow's dialog branch (or drag it onto the **LTX Director** audio track with `use_custom_audio = true`). LTX locks the audio latent and lip-syncs the character to your recording.
* **DaVinci Resolve clean-audio tip:** Because custom audio goes through the LTX Audio VAE encode/decode cycle, it can pick up slight VAE artifacts in the saved MP4. For the cleanest final sound:
  1. Feed your **original WAV** into ComfyUI so LTX matches lip-sync and timing.
  2. In **DaVinci Resolve**, place that **same original clean WAV** on the audio track aligned with the clip and mute the MP4's VAE-decoded voice (or blend lightly if you want LTX's background SFX), then mix music and SFX on separate tracks.

### Step 3 — Building the Full Video in DaVinci Resolve
1. Render each 5–8 s shot separately in ComfyUI (using the saved `last_frame` PNG whenever Shot 2 continues directly from Shot 1).
2. Import your best takes into **DaVinci Resolve** on a matching **24 fps** timeline.
3. Trim 1–3 frames off joins or starts if there is a slight seam or repeated frame on continuation cuts.
4. Do light color/exposure matching between shots so consecutive clips feel cohesive, layer clean voice + music + SFX, and export your finished video.

---

## 9. How to Use the MSR Workflows (Parent Folder `comfyui-workflows/`)

The 3 MSR workflows live one folder up (`comfyui-workflows/`):
* `../LTX-2.5_MSR_MultiRef_TwoStage_GGUF.json` — pure multi-subject reference (up to `pic1..pic4` + `background`), 2-stage.
* `../LTX-2.5_MSR_Keyframes_Dialog_TwoStage_GGUF.json` — **MSR identity refs + START/MID-A/MID-B/END keyframes + optional dialog**, 2-stage.
* `../LTX-2.5_MSR_Keyframes_Dialog_SingleStage_GGUF.json` — same as above, **1-stage only**.

### When to use MSR vs Keyframes / LTX Director
* **Keyframes / LTX Director** anchor **what happens at specific timestamps** (poses, camera moves, story beats).
* **MSR (Multiple Subject Reference)** locks **character / object / background identity** across angles and cuts using LiconStudio's MSR V2 LoRA. Use MSR if characters lose their face/outfit consistency in plain keyframe workflows.

### Setup for MSR
1. Install custom node:
   ```bash
   cd ComfyUI/custom_nodes
   git clone https://github.com/liconstudio/ComfyUI-LTX2.5-MSR
   ```
2. Download `LTX-2.5-Licon-MSR-V2.safetensors` from `LiconStudio/LTX-2.5-Multiple-Subject-Reference` into `ComfyUI/models/loras/`.
3. Restart ComfyUI.
4. In **Group 1**, select your model files (the MSR JSONs default to official filenames like `ltx-2.5-22b-distilled-Q6_K.gguf` — switch them to your `ltx25_uncensored_*` files if those are what you have installed).

### How to run MSR
1. Load character/object portraits into **`pic1`** (required), **`pic2`**, **`pic3`**, **`pic4`**, and optional **`background`**.
   * References must be **contiguous** (`pic1`, `pic2`, … with no gaps).
   * If you use fewer references (e.g. only `pic1` and `pic2`), disconnect unused `picN` wires from **both** Stage 1 and Stage 2 `ComfyUI-LTX2.5-MSR Multi-Reference Guide` nodes.
2. In your **positive prompt**, explicitly label them as **`Image 1`**, **`Image 2`**, **`Image 3`**… and describe who does what (e.g. *"Image 1 stands on the left talking to Image 2 on the right in the room from Image 3"*).
3. **Always keep `LTXVCropGuides` active** — it strips both the MSR reference tokens and any keyframe guides before VAE decode.
4. **Resolution & Length for MSR (3090 24 GB):** MSR adds extra reference tokens so VRAM usage is higher than plain I2V.
   * Start at **`832×480`** (2-stage → `1664×960`) or **`768×448`** (2-stage → `1536×896`) and **`5s`** (`121` frames @ 24 fps).
   * Width/height must be divisible by 32; length snaps automatically to `8n + 1`.
5. **Voice refs (`audio_ref1` / `audio_ref2`):** These are for speaker-voice identity (requires an AVref MSR LoRA), *not* full dialogue tracks. For pre-recorded dialogue lip-sync, use Group 4c (`DIALOG audio`) instead.

---

## 10. RTX 3090 (24 GB) Troubleshooting Checklist

If you hit Out-Of-Memory (OOM) or very slow steps ("loaded partially" in console):
1. Lower **`VAEDecodeTiled` `tile_size`**: `512` → `384` → `256`.
2. In **LTX Director**, set `use_tiled_encode = true` on both `LTXDirectorGuide` nodes.
3. Reduce resolution (e.g. `1024×1024` → `768×768`, or `960×544` → `768×448`) or duration (`10s` → `8s` → `5s`).
4. Try a slightly smaller GGUF (`UD-Q5_K_XL` or `UD-Q4_K_XL` instead of `Q6_K`).
5. Launch ComfyUI with `--use-sage-attention` (add `--reserve-vram 1` if your monitor runs on the 3090). Do **not** use `--highvram`.

---

# Other Local Models & Hardware Notes (Reference)

## Comparison

The table describes local model workflows, not paid API or partner nodes. “Audio-driven” means an existing recording guides the video; that is different from generating a new voice or soundtrack.

| Model | Images and timeline control | Audio | Practical on a 3090 |
| --- | --- | --- | --- |
| [LTX-2.5](https://docs.comfy.org/tutorials/video/ltx/ltx-2-5) | The included workflows use start, end, and optional middle guides; the continuation workflow passes a last frame to the next run; LTX Director adds a visual multi-image + prompt-relay timeline. | Generates synchronized audio. The included custom-audio branches can condition on prerecorded dialogue; the decoded audio is not bit-identical to the input. | Your existing GGUF workflow is the starting point. Resolution, duration, quantization, and optional refinement all affect memory and speed. |
| [MiniMax H3](https://docs.comfy.org/tutorials/video/minimax/minimax-h3) | FL2VA handles first/last images. Ref2VA supports multiple references; chained guide nodes anchor images at chosen frames. | Generates speech, music, and effects with the video. Reference audio can guide voice or requested audio reuse, but exact reproduction or lip-sync is not guaranteed. | Pruned INT8 and dynamic offloading make a 24 GB card usable; the transformer, text encoder, and VAEs do not all fit in VRAM at once. Expect minutes, depending on settings. |
| [Kandinsky 6 Lite / Lite Distill](https://github.com/kandinskylab/kandinsky-6/tree/main/comfyui) | The ComfyUI example uses one image; the native Python pipeline also documents first/last-frame input. Its standard clips are 5 seconds. | Generates synchronized audio. Its [native audio-to-video mode](https://github.com/kandinskylab/kandinsky-6/blob/main/docs/generation_modes.md) keeps the source audio, but cannot combine that audio input with an image in the documented mode. | The 3B Lite transformer and 10-step distilled version are promising lower-cost alternatives, but the complete pipeline also needs encoders, VAEs, and a vocoder. Offloading may still be needed. |
| [LongCat Video / Avatar 1.6](https://github.com/meituan-longcat/LongCat-Video) | Image-to-video and video continuation; Avatar is focused on talking characters rather than arbitrary timed image keyframes. | **Avatar is audio-driven:** supply speech to animate a character; it is not the same as generating a soundtrack. | Large 13.6B model; use a suitable quantized/offloaded setup. A [community ComfyUI Avatar 1.6 workflow](https://github.com/PedroMarinhoDev/ComfyUI-LongCat-Avatar) reports testing on a 24 GB 4090, not this 3090. |
| [HunyuanVideo 1.5](https://docs.comfy.org/tutorials/video/hunyuan/hunyuan-video-1-5) | Text-to-video and image-to-video; the linked ComfyUI example uses one starting image, not arbitrary timeline guides. | Video only in the linked workflows; add audio separately. | ComfyUI targets 24 GB consumer GPUs; reduce resolution or use offloading if needed. Regional license restrictions apply. |
| [FramePack](https://github.com/lllyasviel/FramePack) | Starts from an image and progressively generates longer video. Not a ready-made multiple-timed-keyframe workflow. | No native soundtrack in the linked workflow. | Author reports operation from 6 GB VRAM with memory management, but longer clips still take longer to render. |
| [SkyReels V2 1.3B](https://github.com/SkyworkAI/SkyReels-V2) | Image-to-video or Diffusion Forcing continuation; the latter also documents start/end-frame control. Not the same as arbitrary multiple timeline anchors. | No native soundtrack in the linked V2 workflows. | The project reports roughly 14.7 GB peak VRAM for its 1.3B 540p configuration; other settings may differ. |

**For a specific recorded performance**, the existing LTX custom-audio branch or LongCat Avatar is a better starting point than assuming MiniMax will copy the recording. Keep the original audio and, if exact sound quality is important, put that original track back in an editor and check its alignment. The community LongCat workflow linked above is a single-speaker implementation; the original LongCat project has other variants.

## MiniMax H3 setup for a 3090

### Recommended files: multi-reference and keyframes

Use the local [MiniMax H3: Multiframe Reference template](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-multiframe), which uses **Ref2VA**. The following files are the combination listed by that template. Paths are relative to the ComfyUI installation:

| Folder | File | Approx. download size |
| --- | --- | ---: |
| `models/diffusion_models/` | [minimax_h3_ref2va_pruned_int8_convrot.safetensors](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors) | 21.0 GB |
| `models/text_encoders/` | [qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors) | 15.7 GB |
| `models/vae/` | [minimax_h3_video_vae_int8_convrot.safetensors](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/vae/minimax_h3_video_vae_int8_convrot.safetensors) | 2.8 GB |
| `models/vae/` | [minimax_h3_audio_vae_fp32.safetensors](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/vae/minimax_h3_audio_vae_fp32.safetensors) | 0.6 GB |
| `models/loras/` | [minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors) | 2.0 GB |

These are approximately **42 GB on disk**, not 42 GB of required VRAM. Leave extra disk space for downloads and output. The LoRA is optional for generation, but the template may validate its selection even when Turbo is off. The NVFP4 text encoder works on the 3090 through emulation; it is chosen to save memory, not because the 3090 has native NVFP4 acceleration. The larger [INT8 text encoder](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors) is an alternative if you have enough system RAM and want to compare encoding speed.

Use a recent ComfyUI: its documentation specifies **0.34.0 or newer** for the multiframe template. The model publisher recommends INT8 ConvRot with a compatible PyTorch **CUDA 13.0 or newer** build for optimized kernels. Check your driver and installed PyTorch build first; consider a separate ComfyUI environment or backup rather than breaking your working LTX setup. Model weights may need CPU/RAM offloading. **64 GB system RAM is preferable**; 32 GB has worked in a [documented 3090 setup](https://github.com/tonyd2wild/minimax-h3-local/blob/main/docs/3090-comfyui.md), but can be tight and paging can be very slow.

To check the GPU and CUDA build, run this with the **same Python executable that starts ComfyUI**:

```bash
python -c "import torch; print('PyTorch:', torch.__version__, 'CUDA build:', torch.version.cuda, 'GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'unavailable')"
```

### First test: three timed images

1. In local ComfyUI, open **Template Library → Video → MiniMax H3: Multiframe Reference**, or download the [workflow JSON](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/video_minimax_h3_multiframe_reference.json). Install/select the files above and replace the example images with yours.
2. Start at **16:9, 0.4 MP** (about **864×480**) and **5 seconds**, with `ref_image_size` set to `match`. At 24 fps the template snaps 5 seconds to **124 frames**, or about **5.17 seconds**. Use matching image aspect ratios and consistent characters, scene, and lighting.
3. Use **Add Guide for MiniMax H3** nodes for the images you want at specific moments. For a 124-frame example, guide the start at **0 seconds / frame 0**, the middle at **2.5 seconds / frame 60**, and the end at **5.125 seconds / frame 123**. Connect each guide to the H3 latent and video VAE, and chain their `positive` connections into the guider. Remove or disable unused example guides. If setting `frame_idx` directly, `-1` means the last frame; do **not** enter `-1` in the template's seconds control, which multiplies by 24.
4. The template's first image is a **semantic reference** described as the starting image in the prompt; it is not an explicit frame-0 guide by default. Add a guide at frame 0 as above if you need that anchor. Likewise, an image connected only as a timeline guide is not automatically visible as `<Picture 2>` or `<Picture 3>` to the text encoder: connect it to `ref_images` too if the prompt refers to it by that tag.
5. Describe the action, camera, spoken lines, and sounds in the prompt. For example, identify the person in `<Picture 1>`, describe the continuous action, and use `(S1) ... <d>[English] Hello there.</d>` for dialogue. See the [prompt guide](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide). Guides are conditioning, not a promise of pixel-perfect frames, identity, or flawless speech.
6. Enable the template's **Lightning LoRA** switch for a 4-step draft. Turn it off for the template's 20-step base render when you need more motion, reference, or audio fidelity. Do not simply reduce the base model's step count without its matching LoRA and schedule.

The [LightX2V Turbo guide](https://github.com/ModelTC/Minimax-H3-Turbo/blob/main/COMFYUI_SETUP_AND_INFERENCE.md) also supplies its own Ref2VA workflow. Its author specifies Euler and video/audio shifts of 12/3 for this 544p LoRA. Follow the relevant workflow's settings when experimenting; LoRA, sampler, and schedule should be matched rather than mixed at random.

### Other fast H3 choices

- **Only a first and/or last image?** Use the [local I2V template](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native#minimax-h3-image-to-video-i2v), [minimax_h3_fl2va_pruned_int8_convrot.safetensors](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors), and its matching [minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors). The text encoder and VAEs are shared with Ref2VA. This is a separate diffusion model and LoRA; **do not substitute the FL2VA 8-step LoRA for the Ref2VA 4-step LoRA**. See the template for [download links and settings](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native).
- **Want an 8-step multi-reference experiment?** Alibaba's [Ref2VA PDD 8-step adapter](https://huggingface.co/alibaba-pai/MiniMax-H3-Acc-LoRAs) is a different adapter and requires a [matching custom ComfyUI node and schedule](https://github.com/Jalen-Brunson/ComfyUI-MiniMax-H3-PDD-Acc). It is not the FL2VA 8-step LoRA, and should not be stacked with the normal Turbo LoRA. Treat it as an advanced alternative, not a drop-in replacement.
- **FastH3** is a separate distilled 8-step checkpoint, not a LoRA. [ComfyUI provides T2V and first/last-frame examples](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fastvideo), but the [FastVideo model card](https://huggingface.co/FastVideo/FastVideo-FastH3-8-Step-V2) says it was distilled for text-to-video, not FL2VA or Ref2VA. Test first/last-frame quality and your 3090's sparse-attention compatibility; it is not the choice for this multi-reference workflow.

### Reducing wait time and memory pressure

- **Draft small and short.** Start around 864×480 and 5 seconds; use `match` for reference images. High-resolution or many reference images/videos add work to every sampling step. Raise the size and duration only after the scene works.
- **Use the matching Turbo mode**, then compare against 20-step base for the final. Fewer steps reduce sampling time, but the result may have weaker motion, audio, or reference adherence and does not necessarily use less peak VRAM.
- **Keep the default dynamic memory management initially.** Close other GPU-heavy apps. If system RAM fills or the process is killed, reduce size or duration; a [3090 Linux report](https://github.com/tonyd2wild/minimax-h3-local/blob/main/docs/3090-comfyui.md) used `--disable-pinned-memory` and swap on a 32 GB machine. That is a troubleshooting option, not a universal speed boost. An SSD and adequate free RAM help avoid costly paging.
- **Try attention optimizations only after a baseline works.** SageAttention or sparse attention can help some setups but require compatible builds and can alter results. One [3090 test](https://comfylab.dev/blog/workflows/minimax-h3-comfyui-speed-vram-rtx-3090) found a speedup, while [another test](https://github.com/Rinne414/ComfyUI-MiniMaxH3-Tools/tree/master/research) found little difference against its existing backend. Compare the output, including audio, on your own machine.
- **Keep expectations realistic.** One [3090 test](https://comfylab.dev/blog/workflows/minimax-h3-comfyui-pdd-acc-vs-turbo-lora-rtx-3090) reported about **80 seconds** for a 5.17-second, 832×480 Ref2VA clip with 4-step Turbo. This is one setup and scene, not a promise for your PC; longer clips, extra references, cold loading, and different settings can be much slower.

The local H3 base model targets a 768-pixel short edge; the vendor's Context-IR and 2K regeneration services are not included in the open-weight release. A separate local upscale is possible, but it is not the same as the hosted 2K pipeline.

## RTX Spark N1X laptop vs. RTX 3090

**Yes, a sufficiently equipped RTX Spark N1X laptop can run MiniMax H3 locally.** NVIDIA lists a 6,144-GPU-core N1X laptop configuration with **up to 128 GB unified memory**, and a smaller 5,120-core laptop configuration with **up to 32 GB**. Check the actual laptop and installed RAM: not every N1X has 128 GB. The CPU, GPU, and operating system share that memory, and Windows imposes GPU budgets; it is not all free VRAM. See [NVIDIA's specifications](https://www.nvidia.com/en-us/products/rtx-spark/specifications/) and [memory guidance](https://docs.nvidia.com/rtx-spark/rtx-spark-porting-guide/latest/uma/umacuda.html).

**More memory does not automatically make it faster.** A 128 GB model can keep larger working sets in shared memory and avoid some 3090-to-system-RAM transfers, but the laptop has a different GPU, power budget, and memory bandwidth. NVIDIA lists approximately **300 GB/s** shared-memory bandwidth for RTX Spark versus **936 GB/s** peak VRAM bandwidth for the 3090; these are theoretical figures, not a direct speed ratio ([N1X](https://docs.nvidia.com/rtx-spark/rtx-spark-porting-guide/latest/overview.html), [3090](https://www.nvidia.com/content/PDF/nvidia-ampere-ga-102-gpu-architecture-whitepaper-v2.1.pdf)). Offloading, compute, kernels, and thermals can change which machine wins.

One [self-reported comparison](https://www.reddit.com/r/LocalLLM/comments/1xr8hbs/benchmarking_rtx_3090_stock_and_with_a_tensorrate/) used the same H3 model files and 20-step ComfyUI workflows on a **128 GB RTX Spark N1X** and a **stock 3090**. For 124-frame (about 5.17-second), 832×480 image-to-video, it reported **15.06 vs 8.20 seconds per sampling step**, respectively; across its tested rows the stock 3090 was about **1.25–1.84× faster per step**. These are warmed-up sampling times, not complete render times. The systems used different PyTorch builds and Windows architectures; this is one comparison, not a guarantee for another laptop or workflow.

RTX Spark runs Windows on Arm, so verify that ComfyUI, PyTorch/CUDA, and any custom nodes or attention kernels support that environment. RTX Spark **N1X is not the same product as DGX Spark GB10**, despite both being Grace/Blackwell systems. For a fair test, compare the same workflow, references, resolution, duration, steps, and seed, recording both warm-run sampling time and total time.
