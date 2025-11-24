You are a professional cinematographer and story editor specializing in AI video generation workflows.

I need you to help me create a detailed scene-by-scene JSON timeline for generating long-form videos using AI video models.

CRITICAL RULES:

1. Each scene needs a complete, detailed prompt that includes ALL environment details (colors, lighting, furniture, atmosphere)
2. The AI has NO memory between scenes - every prompt must be self-contained
3. Include the base environment description in EVERY single prompt
4. Each scene should focus on ONE specific action or moment
5. Use cinematic language (camera angles, lighting, atmosphere)
6. Duration should match the pacing: quick cuts (3-5s), normal action (5-8s), dramatic moments (8-12s)

OUTPUT FORMAT:
Return ONLY valid JSON in this exact format:
[
{
"prompt": "Full detailed description including environment + action",
"duration": 5
},
...
]

EXAMPLE OF GOOD PROMPTS:
✓ "Modern kitchen with white cabinets, marble countertop, stainless steel appliances, bright morning sunlight through window - woman in blue apron cracking eggs into glass bowl"
✓ "Modern kitchen with white cabinets, marble countertop, stainless steel appliances, bright morning sunlight through window - close-up of hands whisking eggs vigorously"

EXAMPLE OF BAD PROMPTS:
✗ "Woman cracks eggs" (missing environment details)
✗ "She continues cooking" (no context of location/environment)

When I provide a story idea, you will:

1. Ask clarifying questions about environment, style, mood, duration
2. Break the story into detailed scenes with proper pacing
3. Output complete JSON ready for AI video generation

Ready? Ask me about my story idea.

```

---

# Usage Examples:

## Example 1: Simple Story Request

**You say:**
```

Create a 2-minute video story about:

- Two cats having a boxing match
- Professional sports setting
- Dramatic and exciting

````

**LLM will respond with full JSON like:**
```json
[
  {
    "prompt": "Professional boxing ring with bright overhead spotlights, red and blue corner posts, crowd silhouettes in dark background, dramatic atmospheric lighting - empty ring establishing shot, wide angle",
    "duration": 5
  },
  {
    "prompt": "Professional boxing ring with bright overhead spotlights, red and blue corner posts, crowd silhouettes in dark background, dramatic atmospheric lighting - first anthropomorphic cat in red boxing gloves and shorts walking down aisle with confident swagger",
    "duration": 5
  },
  ...
]
````

## Example 2: Detailed Story with Specific Requirements

**You say:**

```
I want a 5-minute cooking tutorial video:

Environment:
- Modern white kitchen
- Marble countertops
- Stainless steel appliances
- Natural window light

Story:
- Chef makes pasta from scratch
- Shows every step clearly
- Ends with plated dish

Style: Clean, professional, appetizing
```

## Example 3: Multiple Location Story

**You say:**

```
Create a 3-minute romantic scene:

Location 1: Park bench (1 minute)
- Couple meets, talks, laughs

Location 2: Coffee shop interior (1 minute)
- They have coffee together
- Chemistry builds

Location 3: Park at sunset (1 minute)
- First kiss
- Romantic ending

Make it feel natural and emotional
```

## Example 4: Asking LLM to Expand Existing Story

**You say:**

```
I have this basic story outline. Expand it into a detailed 10-minute scene-by-scene JSON:

Story: Detective investigates a crime scene
- Arrives at mansion
- Examines clues
- Interviews suspects
- Solves the mystery

Environment should be:
- Dark, moody, film noir style
- 1940s aesthetic
- Dramatic shadows and lighting
```

## Example 5: Refining/Editing Existing JSON

**You say:**

```
Here's my current JSON:

[paste your JSON]

Problems:
- Scenes feel rushed
- Need better transitions
- Missing environmental details in some prompts
- Want more dramatic pacing for the climax

Please improve it while keeping the same story.
```

---

# Advanced Prompt for Complex Stories

```
I'm creating a [DURATION]-minute AI-generated video.

STORY CONCEPT:
[Describe your story in 2-3 sentences]

ENVIRONMENTS:
Location 1: [Detailed description - colors, furniture, lighting, mood]
Location 2: [If applicable]
Location 3: [If applicable]

CHARACTERS:
- Character 1: [Description, clothing, personality]
- Character 2: [Description, clothing, personality]

STORY BEATS:
1. [What happens first]
2. [What happens next]
3. [Major turning point]
4. [Climax]
5. [Resolution]

STYLE PREFERENCES:
- Camera work: [e.g., cinematic, documentary, intimate close-ups]
- Pacing: [e.g., slow and contemplative, fast-paced action]
- Mood: [e.g., uplifting, tense, romantic]
- Color palette: [e.g., warm tones, cool blues, high contrast]

SPECIAL REQUIREMENTS:
- [Any specific shots you want]
- [Timing constraints]
- [Important details that must be included]

Please create a detailed scene-by-scene JSON timeline with:
- Complete environment descriptions in every prompt
- Varied scene durations based on pacing (3-12 seconds)
- Smooth story progression
- Cinematic descriptions

Total target: [X] scenes for [Y] minutes of video
```

---

# Quick Reference Card to Keep

Save this for when you chat with LLMs:

```
REMINDER FOR LLM:

✓ Every prompt MUST include full environment (room, colors, lighting, furniture)
✓ Duration: 3-5s (quick), 5-8s (normal), 8-12s (dramatic)
✓ Be specific about actions, camera angles, atmosphere
✓ No pronouns - the AI doesn't remember previous scenes
✓ Include character descriptions each time they appear
✓ Think cinematically - describe what the camera sees

BAD: "She sits down"
GOOD: "Modern office with white walls and glass desk - businesswoman in navy suit sitting in black leather chair, afternoon sunlight streaming through window behind her"

OUTPUT: Valid JSON array only, no explanations outside the JSON
```

---

# Example Full Conversation Flow:

**You:**

```
Create a 5-minute video: A day in the life of a coffee shop barista
```

**LLM:**

```
Great! Let me ask a few questions to make this perfect:

1. Coffee shop style? (modern minimalist / cozy vintage / industrial chic)
2. Time of day? (early morning rush / quiet afternoon / closing time)
3. Barista character? (young woman / experienced man / cheerful personality)
4. Mood? (upbeat and energetic / calm and meditative / busy and stressful)
5. Key moments you want? (latte art / customer interactions / closing routine)

Please provide details and I'll create the complete JSON timeline.
```

**You:**

```
1. Cozy vintage style with brick walls and wooden furniture
2. Early morning to closing (show full day)
3. Young woman, cheerful, skilled
4. Starts calm, gets busy, ends peaceful
5. Show: opening shop, making coffee, rush hour, latte art, friendly chats, closing
```

**LLM:**

```json
[
  {
    "prompt": "Cozy vintage coffee shop with exposed brick walls, dark wooden furniture, warm Edison bulb lighting, vintage coffee equipment, morning golden light through large front windows - empty shop, chairs still on tables, establishing shot",
    "duration": 5
  },
  {
    "prompt": "Cozy vintage coffee shop with exposed brick walls, dark wooden furniture, warm Edison bulb lighting, vintage coffee equipment, morning golden light through large front windows - young woman barista in denim apron unlocking front door, smiling",
    "duration": 5
  },
  ...
]
```

---

# Pro Tips:

1. **Start with LLM** to get the structure
2. **Copy JSON to file**
3. **Manually tweak** any prompts that aren't perfect
4. **Use the Python GUI** to visualize and edit
5. **Re-submit to LLM** if you need major changes
