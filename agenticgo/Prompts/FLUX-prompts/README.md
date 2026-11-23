# FLUX Prompt Director

An image-generation and editing agent prompt set in the same seven-file
structure as `AKS-security/` and `LTX-Prompts/`. Configure your agent
application to load these files using its usual prompt/context mechanism;
the files do not install a model, agent or ComfyUI workflow.

Supports FLUX.2 [klein] 9B and other FLUX image models, with model-specific
features checked rather than assumed. It can write one image prompt, an edit
prompt, or a set of consistent still-image prompts for LTX keyframes.

Example request:

> Using my reference image, write FLUX prompts for three consistent LTX
> keyframes: the woman seated, standing beside the chair, and at the doorway.
> Keep her appearance, the room and the camera angle consistent.

Image inspection requires vision and image tools in your application. If they
are unavailable, describe the reference and the role of each image.
