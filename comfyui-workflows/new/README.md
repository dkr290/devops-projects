# Local video models and LTX workflows



## Comparison

The table describes local model workflows, not paid API or partner nodes. “Audio-driven” means an existing recording guides the video; that is different from generating a new voice or soundtrack.

| Model | Images and timeline control | Audio | Practical on a 3090 |
| --- | --- | --- | --- |
| [LTX-2.5](https://docs.comfy.org/tutorials/video/ltx/ltx-2-5) | The included workflows use start, end, and optional middle guides; the continuation workflow passes a last frame to the next run. | Generates synchronized audio. The included custom-audio branches can condition on prerecorded dialogue; the decoded audio is not bit-identical to the input. | Your existing GGUF workflow is the starting point. Resolution, duration, quantization, and optional refinement all affect memory and speed. |
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

One [self-reported comparison](https://www.reddit.com/r/LocalLLM/comments/1xr8hbs/benchmarking_rtx_3090_stock_and_with_a_tensorrate/) used the same H3 model files and 20-step ComfyUI workflows on a **128 GB ASUS ProArt P16 N1X** and a **stock 3090**. For 124-frame (about 5.17-second), 832×480 image-to-video, it reported **15.06 vs 8.20 seconds per sampling step**, respectively; across its tested rows the stock 3090 was about **1.25–1.84× faster per step**. These are warmed-up sampling times, not complete render times. The systems used different PyTorch builds and Windows architectures; this is one comparison, not a guarantee for another laptop or workflow.

RTX Spark runs Windows on Arm, so verify that ComfyUI, PyTorch/CUDA, and any custom nodes or attention kernels support that environment. RTX Spark **N1X is not the same product as DGX Spark GB10**, despite both being Grace/Blackwell systems. For a fair test, compare the same workflow, references, resolution, duration, steps, and seed, recording both warm-run sampling time and total time.

## Existing LTX workflows

These JSON files are separate from MiniMax and have been preserved:

- [Single-stage GGUF](LTX-2.5_I2V_Keyframes_Dialog_SingleStage_GGUF.json): the original single-stage keyframe workflow, with optional dialogue conditioning.
- [Optional two-stage GGUF](LTX-2.5_I2V_Keyframes_Dialog_OptionalTwoStage_GGUF.json): optional 2× latent upscale and refinement. Its upscaler must be installed and selected even for the stage-1-only path because the loader may be validated. Its custom-audio path relies on newer ComfyUI nested-AV replacement behavior.
- [Three-keyframe manual continuation GGUF](LTX-2.5_I2V_ThreeKeyframes_ManualContinuation_GGUF.json): one clip per run, with start/middle/end guides. It saves a last-frame PNG to use as the next run's start; it does not automatically loop or join clips. Its audio branch uses separate AV latents.

The two added workflows were checked structurally, but **no actual video render or lip-sync test was performed**. Inspect joins and audio timing, and read the notes inside each workflow.




for LTX
Why try Director for a movie?
The second video combines storyboard images with LTX Director. That’s useful because:
You can plan the character, locations and shots as still images first.
Director gives you a visual timeline for placing images and prompts.
You can render scenes and assemble the best takes in an editor.
Director is mainly a way to organize and control generation, not a new video model that automatically makes every frame better. Faces, movement, dialogue and joins still need checking. Use a Director version compatible with LTX 2.5; its workflow may need different model loaders or weights from your GGUF setup.
A sensible test on your 3090
Try one 8-second, 24 fps scene with three related images. Your workflow’s default middle frame, 96, is correct for that duration.
Turn stage 2 off for an initial low-resolution draft. The upscaler still needs to be installed and selected because ComfyUI may validate it.
Compare with the first video’s workflow using the same images, prompt, audio, resolution and fixed seed as closely as possible. Check motion, face consistency and lip-sync—not just sharpness.
The video recommends 10 seconds or longer for its three-frame mode. If you try 10 seconds at 24 fps in your workflow, change the middle frame to 120.
