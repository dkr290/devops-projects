# System prompts for LM Studio

Standalone prompt-writing assistants adapted from the collections in
`agenticgo/Prompts/`. Each folder contains one complete system prompt:

| System prompt | Purpose |
| --- | --- |
| [FLUX-prompts/SYSTEM_PROMPT.md](FLUX-prompts/SYSTEM_PROMPT.md) | FLUX image creation, editing and stills for LTX keyframes |
| [LTX-Prompts/SYSTEM_PROMPT.md](LTX-Prompts/SYSTEM_PROMPT.md) | LTX-2.5 video and image-to-video motion prompts |
| [Qwen-Image-prompts/SYSTEM_PROMPT.md](Qwen-Image-prompts/SYSTEM_PROMPT.md) | Qwen-Image-Edit instructions and edited LTX keyframe stills |

## Use in LM Studio

1. Load an instruction-following chat model that accepts system messages in
   LM Studio.
2. Copy the **entire contents** of one `SYSTEM_PROMPT.md` into the chat's
   **System Prompt** field. You can save it as a named
   [preset](https://lmstudio.ai/docs/app/presets) and repeat for the other two.
   These Markdown files are prompts to paste, not importable preset JSON files.
   If the setting is hidden, enable Developer Mode under **Settings →
   Developer**.
3. In the chat, describe your scenario or desired edit. Include the target
   model, image roles, frame order, duration or other constraints when they
   matter. You can also ask the assistant to revise an existing prompt.
4. Copy the generated prompt, without its label or code fences, into the
   appropriate FLUX, LTX or Qwen workflow. Supply any source/reference images
   to that workflow separately; attaching them to the chat does not
   automatically connect them to the image or video generator.

To discuss an attached image visually, the chat model must support vision and
LM Studio must pass the image to it. Otherwise describe the image and the role
of each reference in text. These system prompts write instructions; they do
not install, run or test the target image/video models.

### Example requests

- **FLUX:** “Create a wide photographic image of a lighthouse on a rocky coast
  at dusk, with soft mist and a warm light in its window.”
- **LTX:** “My start frame shows a woman seated in a room. She stands up and
  walks to the doorway in one continuous six-second shot; keep the camera
  still.”
- **Qwen edit:** “My source image shows a woman in a green coat. Change the
  coat to navy and keep her face, pose, room and lighting consistent.”

## References

- [BFL FLUX prompting reference](https://docs.bfl.ml/guides/prompting_unified_reference)
  and [FLUX.2 pro/max guide](https://docs.bfl.ml/guides/prompting_guide_flux2).
- [LTX prompting guide](https://docs.ltx.io/open-source-model/usage-guides/prompting-guide)
  and [image-to-video guide](https://docs.ltx.io/open-source-model/usage-guides/image-to-video).
- [Qwen-Image-Edit-2511 model card](https://huggingface.co/Qwen/Qwen-Image-Edit-2511)
  and [ComfyUI guide](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511).

Model-specific features and input limits in these references do not necessarily
apply to a different checkpoint, frontend or local workflow.
