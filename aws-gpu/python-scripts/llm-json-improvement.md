You are an expert cinematographer and AI video generation specialist.

I have a JSON timeline for AI video generation. Each scene is generated independently with NO MEMORY of previous scenes.

YOUR TASK: Review and improve my JSON to ensure:

1. CONSISTENCY CHECKLIST:
   ✓ Every prompt contains the COMPLETE base environment (colors, walls, furniture, lighting, atmosphere)
   ✓ Character descriptions are identical across all scenes (same clothing, appearance)
   ✓ Location details never change unless intentionally moving to new location
   ✓ Lighting/time of day remains consistent (or transitions logically)
   ✓ Camera style/perspective is consistent

2. COMPLETENESS CHECKLIST:
   ✓ No vague pronouns ("he", "she", "it") - use full descriptions
   ✓ Every action is clearly described and visible
   ✓ No missing environmental details
   ✓ Proper scene progression and pacing

3. CINEMATIC QUALITY:
   ✓ Add camera angles where helpful (wide shot, close-up, over-shoulder)
   ✓ Enhance atmospheric details (lighting, mood, energy)
   ✓ Improve action descriptions to be more visual and specific
   ✓ Better scene transitions and flow

4. DURATION OPTIMIZATION:
   ✓ Quick establishing shots: 3-5s
   ✓ Normal action: 5-8s  
   ✓ Important dramatic moments: 8-12s
   ✓ Suggest duration changes if pacing feels off

RULES:

- Keep the same story and scene count (unless I ask you to add/remove scenes)
- Maintain the original intent of each scene
- Only fix inconsistencies and improve clarity
- Flag any scenes that seem problematic
- Return complete valid JSON

OUTPUT FORMAT:
First, provide a brief summary of issues found and improvements made.
Then, provide the complete improved JSON.

Here's my JSON:

[PASTE YOUR JSON HERE]

```

---

## 📋 Quick Version (Shorter Prompt):

```

I need you to review and improve this AI video generation JSON.

CRITICAL: Each scene is generated independently - the AI has NO MEMORY between scenes!

Check and fix:
✓ Every prompt must include FULL environment details (colors, furniture, lighting, walls)
✓ Character descriptions must be identical in every scene they appear
✓ No pronouns - always use complete descriptions
✓ Consistent lighting, time of day, location details
✓ Clear, specific, visual action descriptions
✓ Proper scene durations (3-5s quick, 5-8s normal, 8-12s dramatic)

Keep the same story and scene count. Only fix inconsistencies and improve clarity.

Here's my JSON:

[PASTE YOUR JSON HERE]

````

---

## 🎬 Example Usage:

### Your JSON (with problems):
```json
[
  {
    "prompt": "Modern kitchen, woman cooking",
    "duration": 5
  },
  {
    "prompt": "She adds ingredients to the pan",
    "duration": 5
  },
  {
    "prompt": "The food is ready, she plates it",
    "duration": 5
  }
]
````

### LLM Response:

```
ISSUES FOUND:
1. Missing detailed environment descriptions in all scenes
2. Character inconsistency - no description of woman's appearance/clothing
3. Using pronouns "she" instead of full descriptions
4. Vague actions - "cooking" and "adds ingredients" not specific enough
5. No lighting or atmosphere details
6. Scene 3 could benefit from longer duration for final reveal

IMPROVEMENTS MADE:
- Added complete kitchen environment to every prompt
- Consistent character description (woman in white chef's coat, dark hair in bun)
- Removed all pronouns, used full descriptions
- Made actions specific and visual
- Added lighting and atmosphere
- Adjusted final scene to 8s for better pacing

IMPROVED JSON:

[
  {
    "prompt": "Modern kitchen with white subway tile backsplash, stainless steel appliances, black granite countertop, wooden cutting board with fresh vegetables, warm overhead pendant lighting, afternoon sunlight through window - woman in white chef's coat with dark hair in bun standing at counter preparing ingredients, wide establishing shot",
    "duration": 5
  },
  {
    "prompt": "Modern kitchen with white subway tile backsplash, stainless steel appliances, black granite countertop, warm overhead pendant lighting, afternoon sunlight through window - woman in white chef's coat with dark hair in bun adding diced tomatoes and herbs into sizzling pan on stovetop, close-up of hands and pan, steam rising",
    "duration": 5
  },
  {
    "prompt": "Modern kitchen with white subway tile backsplash, stainless steel appliances, black granite countertop, warm overhead pendant lighting, afternoon sunlight through window - woman in white chef's coat with dark hair in bun carefully plating finished pasta dish on white ceramic plate, garnishing with fresh basil leaf, detailed plating shot",
    "duration": 8
  }
]
```

---

## 🔧 Specific Fix Requests:

### If you want to focus on specific issues:

```
Review this JSON and specifically:

1. Make sure the room color/furniture is identical in every scene
2. The main character should wear [specific clothing] - make it consistent
3. Check that lighting matches (it's supposed to be sunset/golden hour throughout)
4. Fix any vague actions to be more specific and visual

[PASTE JSON]
```

### If you want to add missing details:

```
This JSON works but feels too basic. Please:

1. Add more atmospheric details (lighting quality, mood, energy)
2. Add camera angles where appropriate (close-up, wide shot, etc.)
3. Make actions more cinematic and specific
4. Keep everything else the same

[PASTE JSON]
```

### If you want to verify consistency:

```
Review this JSON ONLY for consistency issues:

- Is the environment description identical across all scenes?
- Are character descriptions (clothing, appearance) consistent?
- Are there any pronouns that should be full descriptions?
- Does anything change that shouldn't?

Just list the issues found, don't rewrite yet.

[PASTE JSON]
```

---

## 💡 Advanced: Multi-Location Story Check

```
This JSON has multiple locations. Please verify:

Location 1 (Scenes 1-5): [Kitchen description]
Location 2 (Scenes 6-10): [Living room description]
Location 3 (Scenes 11-15): [Bedroom description]

Check that:
✓ Each location's description is consistent within its scenes
✓ Transitions between locations are clear
✓ Characters maintain consistent appearance across all locations
✓ Time of day progression makes sense

Flag any inconsistencies and suggest fixes.

[PASTE JSON]
```

---

## 📝 Comparison Request:

```
I want to compare before/after.

Please:
1. Show me 3 examples of the most improved prompts (before → after)
2. List all consistency issues you fixed
3. Suggest any additional improvements I should consider
4. Provide the complete improved JSON

Original JSON:
[PASTE JSON]
```

---

## ✅ Quick Checklist Prompt:

```
Run this checklist on my JSON and tell me what needs fixing:

□ Every prompt has complete environment (walls, furniture, colors, lighting)
□ Character descriptions identical in all appearances
□ No pronouns ("he/she/it/they") - all full descriptions
□ Location details never change (unless intentional scene change)
□ Lighting/atmosphere consistent
□ Actions are specific and visual (not vague)
□ Durations make sense for pacing
□ Scene progression is logical
□ No missing details that would cause visual inconsistency

Just give me the checklist results and list of specific fixes needed.

[PASTE JSON]
```

---

## 🎯 My Recommended Workflow:

1. **Create your rough JSON** (manually or with GUI)
2. **Use the main improvement prompt** above
3. **Review LLM's changes**
4. **Ask follow-up questions** if needed:
   - "Make scene 5 more dramatic"
   - "The kitchen description feels too long, simplify but keep key details"
   - "Add more emotion to the character actions"
5. **Fine-tune manually** any last details
6. **Run one final consistency check** with the checklist prompt

This way LLM does the heavy lifting of consistency checking and detail enhancement, while you maintain creative control! 🚀

**Save these prompts** - you'll use them for every video project!
