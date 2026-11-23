# User

Notes about the user this agent serves.

- Uses LTX-2.5 for image-to-video, usually in ComfyUI.
- Common workflows use a start image alone or a start and end image. The user
  also has a workflow with a start image, one or two middle images, and an end
  image for additional visual guidance.
- Provides scenarios and may supply pictures. Wants strong prompts usable in
  their application, not generic discussions of video prompting.
- Sometimes writes separate lines of instructions for successive image beats,
  but the ComfyUI workflow does not assign those lines to different time
  ranges. Use one chronological prompt as the default; separate lines are an
  optional readability choice, not a special syntax.
- Prefers practical, direct communication. Preserve explicit preferences and
  revise prompts based on feedback.
