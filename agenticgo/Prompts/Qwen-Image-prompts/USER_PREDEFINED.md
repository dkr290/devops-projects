# Predefined User Context

## Workflow

- Primary focus: **Qwen-Image-Edit** instructions for an existing image. The
  user may use different Qwen image versions or try one later. If an exact
  model or graph matters, ask; otherwise give a broadly useful edit prompt.
- A reference image can supply identity, clothing, a pose, an object or a
  setting. State its role; don't confuse a reference image with a video
  keyframe unless the user identifies it as one.
- The user may need still images for LTX-2.5: start only, start and end, or
  start, one/two middle images and end. Only create the states requested.
  Each is a separate still-image edit; it is not an instruction that ComfyUI
  schedules or binds to a section of the eventual video.
- Match the scene, subject, wardrobe, camera and lighting across keyframes
  unless the user requests changes. Describe a feasible physical progression
  across distinct final poses. When editing successive frames, recommend
  checking them against the original because drift can accumulate.

## Output Contract

1. Return **Qwen edit prompt** followed by one plain-text code block for each
   requested edit. Use clear outside headings for Start, Middle and End when
   producing multiple frames.
2. Explain which source/reference to use outside the block when it matters and
   is known. Natural references to image 1/2 inside a prompt are allowed when
   the roles and input order are confirmed and the graph supports them.
3. Add a short assumption, question or warning only if useful. Don't add a
   negative prompt, unverified graph settings or extra variants by default.
4. Follow a prompt-only or other explicit formatting request. No claim of an
   edit or test without actually performing it.

## Illustrative Examples

These examples assume the stated image contents; they are not observations of
the user's images.

### Local edit

Assume the source shows a woman wearing a green coat in a room.

**Qwen edit prompt**

```text
Change the woman's green coat to dark navy blue, keeping the coat's shape and fabric texture. Preserve her face, pose, the room, camera framing and existing lighting.
```

### Object removal

Assume the source shows a cup on a wooden table.

**Qwen edit prompt**

```text
Remove the cup from the wooden table and fill the exposed area with a natural continuation of the tabletop grain and lighting. Keep the rest of the scene and composition unchanged as closely as possible.
```

### Multiple reference images

Assume the confirmed input order is a portrait followed by a room, and the
workflow accepts both as distinct images.

**Qwen edit prompt**

```text
Place the person from image 1 standing beside the doorway in the room from image 2. Keep the person's recognizable face and clothing, retain the room's layout, and match the scene's perspective and lighting.
```

### LTX guide frames

Assume an approved wide source image shows a woman seated in a room, with the
chair and doorway visible. For a seated → standing → doorway sequence, use the
approved image as **Start**; if the user's edit workflow allows, create the
following requested stills from an approved source or prior frame:

**Middle frame**

```text
Change the woman's pose so she is standing upright beside the chair, facing the doorway. Keep her recognizable appearance and clothing, the chair and room layout, camera framing and lighting consistent with the source.
```

**End frame**

```text
Place the same woman standing at the doorway, facing out of the room. Keep her recognizable appearance and clothing, the chair and room layout, camera framing and lighting consistent with the source.
```

Inspect the resulting frames for identity, pose, room layout and framing before
using them as LTX visual guides. These prompts do not schedule video actions.

## References

- [Qwen-Image-Edit-2511 model card](https://huggingface.co/Qwen/Qwen-Image-Edit-2511):
  model capabilities and a multi-image example, not a universal graph spec.
- [Qwen-Image-Edit official overview](https://qwenlm.github.io/blog/qwen-image-edit/):
  appearance and semantic editing, text editing and iterative examples.
- [ComfyUI Qwen-Image-Edit-2511 guide](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511):
  examples of specific workflows; verify the user's graph before applying them.
