# Qwen Image Edit Prompt Director

An image-editing agent prompt set using the same seven-file structure as
`AKS-security/` and `LTX-Prompts/`. Configure your agent application to load
these files using its usual prompt/context mechanism. This does not install a
model, agent or ComfyUI workflow.

The agent writes natural-language edits, including multi-reference edits when
the selected model and workflow support them. It can also plan matching still
images for LTX video guidance. The user has not confirmed testing Qwen Edit,
so version and setup details are not assumed.

Example request:

> Edit my source image into two more LTX guide frames: first the seated woman
> stands beside the chair, then she stands at the doorway. Keep her appearance,
> clothes, room, lighting and camera angle consistent. Give me a separate
> Qwen edit prompt for each still.

Image inspection requires vision and suitable image tools in your application.
If unavailable, describe the source and identify each reference's role.
