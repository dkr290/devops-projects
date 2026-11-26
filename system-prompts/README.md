# System prompts for LM Studio

Standalone prompt-writing assistants adapted from the collections in
`agenticgo/Prompts/`. Each folder contains one complete system prompt:

| System prompt | Purpose |
| --- | --- |
| [FLUX-prompts/SYSTEM_PROMPT.md](FLUX-prompts/SYSTEM_PROMPT.md) | **FLUX Text-to-Image (T2I)** — creating brand-new characters, backgrounds, and stills from scratch |
| [FLUX-I2I-prompts/SYSTEM_PROMPT.md](FLUX-I2I-prompts/SYSTEM_PROMPT.md) | **FLUX.2 Image-to-Image & Multi-Ref (I2I)** — editing a source still or merging `image 1` + `image 2` without re-describing the subject from scratch |
| [Qwen-Image-prompts/SYSTEM_PROMPT.md](Qwen-Image-prompts/SYSTEM_PROMPT.md) | **Qwen-Image (original)** — general Qwen-Image-Edit instructions |
| [Qwen-Image-I2I-prompts/SYSTEM_PROMPT.md](Qwen-Image-I2I-prompts/SYSTEM_PROMPT.md) | **Qwen-Image-Edit Strict I2I & Multi-Ref** — anchors directly to *"the same person from image 1"* / *"the background from image 2"* (no T2I re-description drift) |
| [LTX-Prompts/SYSTEM_PROMPT.md](LTX-Prompts/SYSTEM_PROMPT.md) | **LTX-2.5 prose prompts** (I2V, FLF, DFR, MSR and LTX Director) |
| [LTX-IC-LoRA-Prompts/SYSTEM_PROMPT.md](LTX-IC-LoRA-Prompts/SYSTEM_PROMPT.md) | **LTX-2.5 baked IC-LoRA structured prompts** (`[VISUAL]:` / `[SPEECH]:` / `[SOUNDS]:`, `Unscored`) |
| [Minimax-H3-prompts/SYSTEM_PROMPT.md](Minimax-H3-prompts/SYSTEM_PROMPT.md) | **MiniMax H3 & Pika H3 Flex** structured Ref2VA, FL2VA and T2VA multimodal prompts |

## Use in LM Studio

1. Load an instruction-following chat model that accepts system messages in
   LM Studio.
2. Copy the **entire contents** of one `SYSTEM_PROMPT.md` into the chat's
   **System Prompt** field. You can save it as a named
   [preset](https://lmstudio.ai/docs/app/presets) and repeat for the other
   prompts.
   These Markdown files are prompts to paste, not importable preset JSON files.
   If the setting is hidden, enable Developer Mode under **Settings →
   Developer**.
3. In the chat, describe your scenario or desired edit. Include the target
   model, image roles, frame order, duration or other constraints when they
   matter. You can also ask the assistant to revise an existing prompt.
4. Copy the generated prompt, without its label or code fences, into the
   appropriate FLUX, LTX, MiniMax / Pika H3 or Qwen workflow. Supply any
   source/reference images to that workflow separately; attaching them to the
   chat does not automatically connect them to the image or video generator.

To discuss an attached image visually, the chat model must support vision and
LM Studio must pass the image to it. Otherwise describe the image and the role
of each reference in text. These system prompts write instructions; they do
not install, run or test the target image/video models.

### Example requests

- **FLUX (T2I):** “Create a wide photographic image of a lighthouse on a rocky
  coast at dusk, with soft mist and a warm light in its window.”
- **FLUX / Qwen (I2I / Multi-Ref):** “Image 1 is my character, image 2 is a
  16:9 garden background. Place her standing on the path in the garden, keeping
  her exact face and outfit.”
- **LTX (prose):** “My start frame shows a woman seated in a room. She stands
  up and walks to the doorway in one continuous six-second shot; keep the
  camera still.”
- **LTX (IC-LoRA tags):** “I2V, 5 seconds. Start frame is a man at a café
  table. He laughs, lifts his coffee cup, and says ‘Alright, let’s make a
  deal.’ Café ambience only, no background music.”
- **MiniMax / Pika H3 Flex:** “Ref2VA, 5 seconds. Picture 1 is our pilot,
  Picture 2 is a sci-fi corridor. She walks down the corridor toward the camera
  and says ‘We’re clear for launch.’ Keep natural corridor hum, no music.”
- **Qwen edit:** “My source image shows a woman in a green coat. Change the
  coat to navy and keep her face, pose, room and lighting consistent.”

## References

- [BFL FLUX prompting reference](https://docs.bfl.ml/guides/prompting_unified_reference)
  and [FLUX.2 pro/max guide](https://docs.bfl.ml/guides/prompting_guide_flux2).
- [LTX prompting guide](https://docs.ltx.io/open-source-model/usage-guides/prompting-guide),
  [image-to-video guide](https://docs.ltx.io/open-source-model/usage-guides/image-to-video),
  and [ComfyUI LTX-2.5 docs](https://docs.comfy.org/tutorials/video/ltx/ltx-2-5).
- [ComfyUI MiniMax H3 Prompt Guide](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide)
  and [Pika H3 Flex docs](https://docs.comfy.org/tutorials/video/pika/pika-h3-flex).
- [Qwen-Image-Edit-2511 model card](https://huggingface.co/Qwen/Qwen-Image-Edit-2511)
  and [ComfyUI guide](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511).

Model-specific features and input limits in these references do not necessarily
apply to a different checkpoint, frontend or local workflow.
