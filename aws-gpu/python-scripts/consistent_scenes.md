## Pro Tip: Use a Python Helper Script

Create `create_story.py` to make this easier:

```python
#!/usr/bin/env python3
"""
Helper script to generate story JSON with consistent environment descriptions
"""

import json
import argparse

def create_story_with_base(base_environment: str, scenes: list, output_file: str):
    """
    Create story JSON with base environment prepended to each scene

    Args:
        base_environment: Common description (room, lighting, style)
        scenes: List of dicts with 'action' and 'duration'
        output_file: Output JSON filename
    """
    timeline = []

    for scene in scenes:
        full_prompt = f"{base_environment} - {scene['action']}"
        timeline.append({
            "prompt": full_prompt,
            "duration": scene.get('duration', 5)
        })

    with open(output_file, 'w') as f:
        json.dump(timeline, f, indent=2)

    print(f"✓ Created {output_file} with {len(timeline)} scenes")
    print(f"  Base environment: {base_environment}")


# Example usage
if __name__ == "__main__":
    # Define your consistent environment
    BASE_ENV = "Modern office with white walls, glass desk, black leather chairs, city view through large windows, bright daylight"

    # Define just the ACTIONS (what changes)
    SCENES = [
        {"action": "empty office, establishing shot", "duration": 5},
        {"action": "door opens, businesswoman in navy suit enters carrying briefcase", "duration": 5},
        {"action": "businesswoman walks to desk, sets down briefcase", "duration": 5},
        {"action": "businesswoman sits in black leather chair, turns on computer", "duration": 5},
        {"action": "businesswoman typing on keyboard, focused expression", "duration": 8},
        {"action": "knock on door, businesswoman looks up", "duration": 3},
        {"action": "door opens, male colleague in gray suit enters with documents", "duration": 5},
        {"action": "male colleague approaches desk, hands documents to businesswoman", "duration": 5},
        {"action": "businesswoman reviewing documents, male colleague standing and explaining", "duration": 8},
        {"action": "both looking at computer screen together, pointing at data", "duration": 8},
        {"action": "businesswoman nodding in agreement, shaking hands with colleague", "duration": 5},
        {"action": "male colleague exits, businesswoman returns to typing", "duration": 5},
        {"action": "businesswoman stands up, walks to window looking at city view", "duration": 8},
        {"action": "close-up of businesswoman's face, thoughtful expression with city reflection", "duration": 5},
    ]

    create_story_with_base(BASE_ENV, SCENES, "office_scene.json")

    print("\nGenerated prompts preview:")
    for i, scene in enumerate(SCENES[:3]):
        print(f"\n{i+1}. {BASE_ENV} - {scene['action']}")
```

**Run it:**

```bash
python create_story.py
```

**Output `office_scene.json`:**

```json
[
  {
    "prompt": "Modern office with white walls, glass desk, black leather chairs, city view through large windows, bright daylight - empty office, establishing shot",
    "duration": 5
  },
  {
    "prompt": "Modern office with white walls, glass desk, black leather chairs, city view through large windows, bright daylight - door opens, businesswoman in navy suit enters carrying briefcase",
    "duration": 5
  },
  ...
]
```

**Then generate:**

```bash
python story_video_generator.py \
  --story_file office_scene.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B
```

## Advanced: Multiple Locations

If your story has multiple rooms:

```python
SCENES = [
    # Kitchen scenes
    {"env": "Modern kitchen, white cabinets, marble countertop, stainless appliances",
     "action": "woman preparing breakfast", "duration": 5},
    {"env": "Modern kitchen, white cabinets, marble countertop, stainless appliances",
     "action": "man enters, kisses woman good morning", "duration": 5},

    # Living room scenes
    {"env": "Cozy living room, beige sofa, fireplace, family photos on wall",
     "action": "couple sitting on sofa drinking coffee", "duration": 8},
    {"env": "Cozy living room, beige sofa, fireplace, family photos on wall",
     "action": "couple laughing together, warm atmosphere", "duration": 5},

    # Bedroom scenes
    {"env": "Elegant bedroom, king bed with white linens, soft morning light",
     "action": "couple getting ready, woman at vanity", "duration": 5},
]

# Generate
timeline = []
for scene in SCENES:
    timeline.append({
        "prompt": f"{scene['env']} - {scene['action']}",
        "duration": scene['duration']
    })
```

## Summary:

🔴 **DON'T rely on AI memory** - it has none!  
🟢 **DO repeat environment details** in every single prompt  
🟢 **DO use helper scripts** to avoid repetitive typing  
🟢 **DO be specific** about colors, furniture, lighting in each prompt

This ensures **visual consistency** across your entire video!
