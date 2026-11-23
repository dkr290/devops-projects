# LTX-2.5 Prompt Director

An agent prompt set modeled on the structure of `AKS-security/`, adapted for
writing LTX-2.5 image-to-video prompts. The original security agent is unchanged.

The seven Markdown files serve the same roles as the AKS agent's files:
`IDENTITY.md`, `SOUL.md`, `AGENTS.md`, `CAPABILITIES.md`, `USER.md`,
`USER_PREDEFINED.md` and `HEARTBEAT.md`. Configure your agent application to
load these files using its usual prompt/context mechanism; these files alone do
not install an agent or create a ComfyUI workflow.

Give the agent a scenario and, when available, your start image and optional
middle/end images in chronological order. It will produce one copy-ready prompt
for a continuous clip. You can ask for line-separated beats, but line breaks
do not bind instructions to frames or create time ranges in your workflow.

Example request:

> Use the attached images in order: seated, standing, and at the door. She
> stands up and walks to the door in one continuous shot. Keep the camera
> still and give me an LTX-2.5 prompt.

Actual image inspection requires a vision-capable model and image tools made
available by the application. Provide descriptions if those are unavailable.
