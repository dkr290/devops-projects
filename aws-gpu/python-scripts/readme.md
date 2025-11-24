**Usage Examples:**

```bash
# For Wan2.1-T2V-1.3B (10 minute video)
python long_video_generator.py \
  --prompt "Two anthropomorphic cats in comfy boxing gear and bright gloves fight intensely on a spotlighted stage." \
  --model t2v-1.3B \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --size 832*480 \
  --duration 600 \
  --segment_duration 5 \
  --output_name cats_boxing_10min.mp4

# For Wan2.2-TI2V-5B (10 minute video, higher quality)
python long_video_generator.py \
  --prompt "Two anthropomorphic cats in comfy boxing gear and bright gloves fight intensely on a spotlighted stage." \
  --model ti2v-5B \
  --ckpt_dir ./Wan2.2-TI2V-5B \
  --size 1280*704 \
  --duration 600 \
  --segment_duration 4 \
  --output_name cats_boxing_hq_10min.mp4

# Shorter test (1 minute)
python long_video_generator.py \
  --prompt "Your prompt here" \
  --model t2v-1.3B \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --duration 60 \
  --segment_duration 5
```

**Key Features:**

1. **Chunking**: Breaks 10min video into manageable segments (default 5s each)
2. **Temporal Consistency**: Extracts last frame of each segment to seed the next
3. **VRAM Management**: Each segment generated independently with `--offload_model`
4. **Automatic Stitching**: Uses FFmpeg to concatenate segments seamlessly
5. **Seed Variation**: Incrementally varies seeds for diversity while maintaining coherence
6. **Cleanup**: Automatically removes intermediate files

**Requirements:**

```bash
pip install ffmpeg-python
# Ensure ffmpeg is installed: apt-get install ffmpeg
```

This approach keeps VRAM usage per segment low while building long videos!

# for V2

**Usage Examples:**

```bash
# 10-minute video (default) - Fast with offloading
python long_video_generator.py \
  --prompt "Two anthropomorphic cats in comfy boxing gear and bright gloves fight intensely on a spotlitted stage." \
  --model t2v-1.3B \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --size 832*480

# 30-minute high-quality video
python long_video_generator.py \
  --prompt "Epic space battle" \
  --model ti2v-5B \
  --ckpt_dir ./Wan2.2-TI2V-5B \
  --size 1280*704 \
  --duration 1800 \
  --convert_model_dtype

# 1-hour video with VACE
python long_video_generator.py \
  --prompt "Nature documentary" \
  --model vace-1.3B \
  --ckpt_dir ./Wan2.1-VACE-1.3B \
  --duration 3600 \
  --segment_duration 8

# 2-hour movie (if you're crazy!)
python long_video_generator.py \
  --prompt "Full movie" \
  --model ti2v-5B \
  --ckpt_dir ./Wan2.2-TI2V-5B \
  --duration 7200 \
  --segment_duration 10
```

**Key Features:**
✅ **Any duration** - 1 min to hours  
✅ **All Wan models** - T2V, TI2V, VACE  
✅ **No `--t5_cpu` by default** (fast mode)  
✅ **24GB VRAM optimized** with `--offload_model`  
✅ **Temporal consistency** between segments  
✅ **Automatic stitching** with FFmpeg  
✅ **Progress tracking** and error handling

# for long story

## How To Use This Properly

### Option 1: Auto Story (Simple but Limited)

```bash
python story_video_generator.py \
  --prompt "Two anthropomorphic cats boxing" \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --duration 300
```

This creates a 5-minute video with automatic scene progression.

### Option 2: Custom Story (Full Control)

Create `boxing_story.json`:

```json
[
  {
    "prompt": "Two anthropomorphic cats in boxing gear entering a spotlit ring, crowd cheering",
    "duration": 5
  },
  {
    "prompt": "Cats touching gloves, referee in background, dramatic lighting",
    "duration": 5
  },
  {
    "prompt": "First cat throws a jab, second cat blocks, defensive stance",
    "duration": 5
  },
  {
    "prompt": "Cats circling each other, testing movements, boxing ring atmosphere",
    "duration": 5
  },
  {
    "prompt": "Second cat counters with a hook, first cat dodges, fast action",
    "duration": 5
  },
  {
    "prompt": "Intense exchange of punches, both cats showing skill, dynamic camera",
    "duration": 8
  },
  {
    "prompt": "First cat lands a powerful uppercut, second cat staggers back",
    "duration": 5
  },
  {
    "prompt": "Second cat recovers, throws combination punches, crowd roaring",
    "duration": 8
  },
  {
    "prompt": "Both cats tired but determined, sweat flying, dramatic lighting",
    "duration": 5
  },
  {
    "prompt": "Final round, first cat charges forward with devastating hook",
    "duration": 5
  },
  {
    "prompt": "Knockout punch lands, second cat falls in slow motion",
    "duration": 8
  },
  {
    "prompt": "Referee counting, winner cat celebrating, crowd going wild",
    "duration": 5
  },
  {
    "prompt": "Victory pose, champion belt raised, confetti falling",
    "duration": 5
  }
]
```

Then run:

```bash
python story_video_generator.py \
  --story_file boxing_story.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B
```

## The Reality Check

✅ **What you CAN do**: Create a video with multiple related scenes that tell a story  
❌ **What you CANNOT do**: Have AI understand and expand a single prompt into a detailed narrative automatically

The AI models are **scene generators**, not **story writers**. You need to provide the story structure yourself!

If you chunk your story into detailed scene descriptions (like the JSON example), you'll get a **much better 10-minute video** with:

✅ **Story progression** - Beginning → Middle → End  
✅ **Scene variety** - Different actions, angles, moments  
✅ **Coherent narrative** - Each scene flows into the next  
✅ **Full prompt coverage** - All details get their moment

---

## Here's What You Need to Do:

### 1. **Write Your Story Breakdown**

For a 10-minute video (600 seconds) with 5-second segments = **120 scenes**

Example `boxing_10min.json`:

```json
[
  // INTRO - Buillights, crow spot dramatic ring with boxing "Empty scenes)
  {"prompt": 6seconds = 30dup (d gathering in background", "duration": 5},
  {"prompt": "Two anthropomorphic cats in hooded robes walking down separate aisles, intense atmosphere", "duration": 5},
  {"prompt": "First cat removes robe revealing bright red boxing gloves and gear, confident pose", "duration": 5},
  {"prompt": "Second cat removes robe showing blue gloves, crowd cheering loudly", "duration": 5},
  {"prompt": "Both cats climb into the ring from opposite corners, referee waiting", "duration": 5},
  {"prompt": "Cats meet at center ring, touching gloves, intense eye contact, referee between them", "duration": 5},

  // ROUND 1 - Feeling each other out (60 seconds = 12 scenes)
  {"prompt": "Bell rings, both cats circle each other cautiously in defensive stance", "duration": 5},
  {"prompt": "Red cat throws testing jab, blue cat slips to the side smoothly", "duration": 5},
  {"prompt": "Blue cat counters with quick jab combination, red cat blocks", "duration": 5},
  {"prompt": "Both cats continue circling, crowd watching intensely, tension building", "duration": 5},
  {"prompt": "Red cat feints left, throws right hook, blue cat ducks under", "duration": 5},
  {"prompt": "Blue cat responds with body shot, red cat steps back", "duration": 5},
  {"prompt": "Red cat against ropes, blocking blue cat's combination punches", "duration": 5},
  {"prompt": "Red cat pushes off ropes with powerful counter hook", "duration": 5},
  {"prompt": "Blue cat stumbles slightly, crowd gasps, dramatic moment", "duration": 5},
  {"prompt": "Both cats reset to center ring, breathing heavy, first round ending", "duration": 5},
  {"prompt": "Bell rings ending round 1, both cats return to corners", "duration": 5},
  {"prompt": "Cats sitting in corners, getting water, coaches talking to them", "duration": 5},

  // ROUND 2 - Action intensifies (90 seconds = 18 scenes)
  {"prompt": "Round 2 bell rings, both cats rush to center with renewed energy", "duration": 5},
  {"prompt": "Red cat throws powerful left hook, connects with blue cat's jaw", "duration": 5},
  {"prompt": "Blue cat shakes it off, fires back with three-punch combination", "duration": 5},
  {"prompt": "Red cat weaves and dodges, counter with uppercut", "duration": 5},
  {"prompt": "Blue cat's head snaps back, crowd roaring loudly", "duration": 5},
  {"prompt": "Intense exchange in center ring, punches flying from both sides", "duration": 8},
  {"prompt": "Red cat lands clean hook, blue cat against ropes taking hits", "duration": 5},
  {"prompt": "Blue cat clinches to slow down red cat's assault, referee separates them", "duration": 5},
  {"prompt": "Blue cat bounces back with aggressive jab cross combination", "duration": 5},
  {"prompt": "Red cat covers up, absorbing punches, looking for opening", "duration": 5},
  {"prompt": "Red cat explodes with devastating body shot, blue cat winces", "duration": 5},
  {"prompt": "Blue cat fires back with head shots, both cats trading blows", "duration": 8},
  {"prompt": "Red cat lands clean right cross, blue cat's mouthguard flies out", "duration": 5},
  {"prompt": "Referee pauses fight briefly, replaces mouthguard, dramatic tension", "duration": 5},
  {"prompt": "Fight resumes, both cats visibly tired but still swinging hard", "duration": 5},
  {"prompt": "Sweat and water droplets flying with each punch, cinematic slow motion", "duration": 8},
  {"prompt": "Round 2 bell rings, both cats exhausted walking to corners", "duration": 5},
  {"prompt": "Corner crews working on both cats, applying ice, giving water", "duration": 5},

  // ROUND 3 - The climax (120 seconds = 24 scenes)
  {"prompt": "Final round bell, both cats stand slowly, determined expressions", "duration": 5},
  {"prompt": "Red cat charges forward aggressively, blue cat ready to counter", "duration": 5},
  {"prompt": "Blue cat sidesteps, lands three quick jabs to red cat's face", "duration": 5},
  {"prompt": "Red cat corners blue cat, unleashing fierce combination punches", "duration": 8},
  {"prompt": "Blue cat slips punches, counters with powerful hook to body", "duration": 5},
  {"prompt": "Red cat doubles over momentarily from body shot impact", "duration": 5},
  {"prompt": "Blue cat follows up with uppercut, red cat's head snaps back", "duration": 5},
  {"prompt": "Red cat against ropes, covering up from blue cat's barrage", "duration": 5},
  {"prompt": "Red cat pushes blue cat away, both reset to center breathing heavy", "duration": 5},
  {"prompt": "Blue cat throws wide hook, red cat ducks and counters perfectly", "duration": 5},
  {"prompt": "Massive right cross from red cat connects clean on blue cat's jaw", "duration": 8},
  {"prompt": "Blue cat's legs wobble, looks dazed, crowd on their feet", "duration": 5},
  {"prompt": "Red cat sensing finish, moves in with combination punches", "duration": 5},
  {"prompt": "Blue cat trying to survive, blocking and moving away desperately", "duration": 5},
  {"prompt": "Red cat cuts off the ring, traps blue cat in corner", "duration": 5},
  {"prompt": "Devastating left hook from red cat, perfect technique, full power", "duration": 8},
  {"prompt": "Blue cat's eyes roll back, knees buckle, dramatic slow motion", "duration": 8},
  {"prompt": "Blue cat falling to canvas in slow motion, dramatic lighting", "duration": 8},
  {"prompt": "Blue cat hits canvas, referee rushes in, starts counting", "duration": 5},
  {"prompt": "Referee counting over fallen blue cat, red cat in neutral corner", "duration": 5},
  {"prompt": "Count reaches ten, referee waves off fight, red cat wins by knockout", "duration": 5},
  {"prompt": "Red cat jumps in celebration, arms raised, crowd exploding", "duration": 8},
  {"prompt": "Medical team checking on blue cat, helping him to sitting position", "duration": 5},
  {"prompt": "Both cats show respect, red cat helps blue cat to feet", "duration": 5},

  // VICTORY - Celebration (90 seconds = 18 scenes)
  {"prompt": "Referee raises red cat's arm in victory, blue cat watching respectfully", "duration": 5},
  {"prompt": "Red cat climbs corner post, raises both arms, crowd cheering wildly", "duration": 5},
  {"prompt": "Confetti starts falling from ceiling, celebration atmosphere", "duration": 5},
  {"prompt": "Championship belt being brought into ring by official", "duration": 5},
  {"prompt": "Belt wrapped around red cat's waist, champion pose", "duration": 8},
  {"prompt": "Red cat and blue cat hug showing sportsmanship, crowd applauds", "duration": 5},
  {"prompt": "Red cat's team rushes into ring, group celebration", "duration": 5},
  {"prompt": "Red cat being lifted on shoulders, belt held high", "duration": 5},
  {"prompt": "Camera flashes everywhere, photographers surrounding the ring", "duration": 5},
  {"prompt": "Red cat posing with belt from multiple angles, champion celebration", "duration": 8},
  {"prompt": "Crowd on feet, waving flags, celebrating the victory", "duration": 5},
  {"prompt": "Replay screen showing the knockout punch in slow motion", "duration": 8},
  {"prompt": "Red cat giving victory speech with microphone, crowd listening", "duration": 5},
  {"prompt": "Both cats raising arms together, mutual respect shown", "duration": 5},
  {"prompt": "Red cat kissing the championship belt, emotional moment", "duration": 5},
  {"prompt": "Final wide shot of ring, confetti falling, crowd celebrating", "duration": 8},
  {"prompt": "Red cat exiting ring with belt, fans reaching out, hero's exit", "duration": 5},
  {"prompt": "Fade to championship belt close-up with red cat's name engraved", "duration": 5}
]
```

### 2. **Run the Generator**

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --size 832*480 \
  --output_name boxing_match_10min.mp4
```

### 3. **What You'll Get**

✅ A **coherent 10-minute boxing match** with:

- Proper story arc (intro → fight → climax → victory)
- Each prompt's details rendered in its own scene
- Smooth progression through the narrative
- All the dramatic moments you described

---

## Pro Tips for Best Results:

### **Scene Duration Strategy:**

```json
{"duration": 5}  // Quick action shots
{"duration": 8}  // Important dramatic moments
{"duration": 3}  // Very fast cuts
```

### **Prompt Engineering for Each Scene:**

- Be **specific** about action in each scene
- Include **camera angles** when needed
- Mention **lighting/atmosphere**
- Describe **key movements**

### **For Even Better Continuity:**

Add these flags when running:

```bash
--convert_model_dtype    # For 5B model quality
--segment_duration 5     # Match your JSON durations
```

---

## The Bottom Line:

**YES** - With proper story chunking, you can generate a full 10-minute (or longer) video that tells a complete story without skipping details!

Each scene gets its own generation, so every detail from your original prompt can be expanded into multiple scenes. The AI just needs you to break down **WHAT happens WHEN** in the story.

Think of it like writing a screenplay with shot-by-shot descriptions!

## Example 1: T2V-1.3B Model (Standard Quality, 24GB VRAM)

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --size 832*480 \
  --segment_duration 5 \
  --seed 42 \
  --output_dir ./boxing_output \
  --output_name boxing_match_10min.mp4
```

## Example 2: TI2V-5B Model (High Quality, 24GB VRAM with optimizations)

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.2-TI2V-5B \
  --model ti2v-5B \
  --size 1280*704 \
  --segment_duration 5 \
  --convert_model_dtype \
  --seed 42 \
  --output_dir ./boxing_output_hq \
  --output_name boxing_match_10min_hq.mp4
```

## Example 3: VACE-1.3B Model (Video + Audio + Camera Effects)

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.1-VACE-1.3B \
  --model vace-1.3B \
  --size 832*480 \
  --segment_duration 5 \
  --seed 42 \
  --output_dir ./boxing_output_vace \
  --output_name boxing_match_10min_vace.mp4
```

## Example 4: Quick Test (1 minute instead of 10)

Create `boxing_test.json`:

```json
[
  {
    "prompt": "Two anthropomorphic cats in boxing gear entering spotlit ring",
    "duration": 5
  },
  {
    "prompt": "Cats touching gloves at center ring, referee between them",
    "duration": 5
  },
  {
    "prompt": "First cat throws powerful jab, second cat blocks",
    "duration": 5
  },
  {
    "prompt": "Cats exchange quick combination punches, intense action",
    "duration": 5
  },
  {
    "prompt": "First cat lands devastating hook, second cat staggers",
    "duration": 5
  },
  {
    "prompt": "Knockout punch connects, second cat falls in slow motion",
    "duration": 5
  },
  {
    "prompt": "Referee counting, winner celebrating, crowd cheering",
    "duration": 5
  },
  {
    "prompt": "Victory pose with championship belt, confetti falling",
    "duration": 5
  },
  { "prompt": "Both cats showing respect, shaking hands", "duration": 5 },
  { "prompt": "Champion cat exiting ring with belt held high", "duration": 5 },
  {
    "prompt": "Final celebration shot, crowd on feet cheering wildly",
    "duration": 5
  },
  {
    "prompt": "Close-up of championship belt with winner's name",
    "duration": 5
  }
]
```

```bash
python story_video_generator.py \
  --story_file boxing_test.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --size 832*480 \
  --segment_duration 5 \
  --output_name test_1min.mp4
```

## Example 5: Using Simple Prompt Instead of JSON (Auto-Story)

```bash
# The script auto-generates scene progression
python story_video_generator.py \
  --prompt "Two anthropomorphic cats in comfy boxing gear fight intensely on a spotlighted stage" \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --size 832*480 \
  --duration 300 \
  --segment_duration 5 \
  --output_name auto_story_5min.mp4
```

## Example 6: Maximum Quality (5B model, high res, with temporal consistency)

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.2-TI2V-5B \
  --model ti2v-5B \
  --size 1280*704 \
  --segment_duration 5 \
  --convert_model_dtype \
  --seed 12345 \
  --output_dir ./max_quality_output \
  --output_name boxing_match_max_quality.mp4
```

## Example 7: Disable Temporal Consistency (if you get errors)

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --size 832*480 \
  --segment_duration 5 \
  --no_temporal_consistency \
  --output_name boxing_no_consistency.mp4
```

## Example 8: Different Story - Nature Documentary (30 min)

Create `nature_30min.json`:

```json
[
  {
    "prompt": "Sunrise over African savanna, golden light, wide landscape",
    "duration": 8
  },
  {
    "prompt": "Lion pride waking up, cubs playing, morning atmosphere",
    "duration": 8
  },
  {
    "prompt": "Lioness stretching, yawning, preparing for hunt",
    "duration": 5
  },
  {
    "prompt": "Herd of gazelles grazing peacefully in distance",
    "duration": 8
  },
  {
    "prompt": "Lionesses moving into hunting formation, low grass",
    "duration": 5
  },
  { "prompt": "Gazelles alert, ears up, sensing danger", "duration": 5 }
  // ... (continue for 30 minutes = 360 scenes)
]
```

```bash
python story_video_generator.py \
  --story_file nature_30min.json \
  --ckpt_dir ./Wan2.2-TI2V-5B \
  --model ti2v-5B \
  --size 1280*704 \
  --segment_duration 8 \
  --convert_model_dtype \
  --output_name nature_documentary_30min.mp4
```

## All Available Flags Explained:

```bash
python story_video_generator.py \
  --story_file <path>              # JSON with scene timeline (RECOMMENDED)
  --prompt <text>                  # Or use simple prompt for auto-story
  --ckpt_dir <path>                # Model checkpoint directory (REQUIRED)
  --model <type>                   # t2v-1.3B, ti2v-5B, vace-1.3B
  --size <WxH>                     # 832*480, 1280*704, etc.
  --segment_duration <seconds>     # Should match your JSON durations (default: 5)
  --duration <seconds>             # Total duration (only with --prompt)
  --seed <number>                  # Base random seed (default: 42)
  --output_dir <path>              # Output directory
  --output_name <file>             # Final video filename
  --convert_model_dtype            # Use for 5B models (better quality)
  --no_offload                     # Don't offload model (needs more VRAM)
  --no_temporal_consistency        # Disable frame-to-frame consistency
```

## Recommended Combos:

### For **Speed** (testing):

```bash
--model t2v-1.3B --size 832*480 --segment_duration 5
```

### For **Quality**:

```bash
--model ti2v-5B --size 1280*704 --segment_duration 5 --convert_model_dtype
```

### For **Long Videos** (1+ hour):

```bash
--segment_duration 8  # Longer segments = fewer total segments
```

Now you're ready to generate professional story-driven videos! 🎬

**NO!** Your JSON can have **different durations for different scenes**. That's the beauty of it! 🎯

## You Can Mix Durations:

```json
[
  { "prompt": "Quick establishing shot of boxing ring", "duration": 3 },
  { "prompt": "Dramatic slow entrance of first cat", "duration": 8 },
  { "prompt": "Quick jab exchange", "duration": 4 },
  { "prompt": "Epic knockout punch in slow motion", "duration": 10 },
  { "prompt": "Fast crowd reaction shot", "duration": 3 },
  { "prompt": "Extended victory celebration", "duration": 12 }
]
```

## The `--segment_duration` Flag

The `--segment_duration` flag is just the **DEFAULT** if you don't specify duration in JSON:

```bash
--segment_duration 5  # Only used if JSON scene doesn't have "duration" field
```

## How It Actually Works:

### Example 1: JSON with mixed durations (BEST)

```json
[
  { "prompt": "Scene 1", "duration": 3 },
  { "prompt": "Scene 2", "duration": 8 },
  { "prompt": "Scene 3", "duration": 5 }
]
```

✅ Result: 3s + 8s + 5s = 16 second video

### Example 2: JSON without durations

```json
[{ "prompt": "Scene 1" }, { "prompt": "Scene 2" }, { "prompt": "Scene 3" }]
```

With `--segment_duration 5`:
✅ Result: 5s + 5s + 5s = 15 second video

### Example 3: Mixed (some have duration, some don't)

```json
[
  { "prompt": "Scene 1", "duration": 8 },
  { "prompt": "Scene 2" },
  { "prompt": "Scene 3", "duration": 10 }
]
```

With `--segment_duration 5`:
✅ Result: 8s + 5s + 10s = 23 second video

## Realistic 10-Minute Boxing Story with Variable Durations:

```json
[
  // INTRO - Quick cuts (3-5 seconds each)
  {
    "prompt": "Empty boxing ring with spotlights, dramatic atmosphere",
    "duration": 3
  },
  {
    "prompt": "Crowd gathering, taking seats, excitement building",
    "duration": 3
  },
  {
    "prompt": "First cat walking down aisle in red robe, confident",
    "duration": 5
  },
  {
    "prompt": "Second cat walking down aisle in blue robe, determined",
    "duration": 5
  },

  // PRE-FIGHT - Medium shots (5-8 seconds)
  {
    "prompt": "Red cat removes robe revealing boxing gear and gloves",
    "duration": 5
  },
  { "prompt": "Blue cat shadow boxing in corner, warming up", "duration": 5 },
  {
    "prompt": "Both cats climb into ring from opposite corners",
    "duration": 5
  },
  { "prompt": "Referee giving instructions at center ring", "duration": 8 },
  { "prompt": "Cats touching gloves, intense staredown", "duration": 8 },

  // ROUND 1 - Mixed pacing
  { "prompt": "Bell rings, both cats circle cautiously", "duration": 5 },
  { "prompt": "Red cat throws testing jab, blue cat slips", "duration": 4 },
  { "prompt": "Blue cat counters with quick combination", "duration": 4 },
  { "prompt": "Intense exchange of punches in center ring", "duration": 8 },
  { "prompt": "Red cat lands clean hook, blue cat stumbles", "duration": 6 },
  { "prompt": "Blue cat against ropes, defending", "duration": 5 },
  { "prompt": "Round 1 bell rings, both return to corners", "duration": 4 },
  { "prompt": "Corner crews working on fighters, giving water", "duration": 8 },

  // ROUND 2 - Faster action (3-6 seconds)
  { "prompt": "Round 2 bell, cats rush to center", "duration": 3 },
  { "prompt": "Rapid punch exchange, both landing shots", "duration": 6 },
  { "prompt": "Red cat powerful left hook", "duration": 4 },
  { "prompt": "Blue cat counter uppercut", "duration": 4 },
  { "prompt": "Both cats trading body shots", "duration": 5 },
  { "prompt": "Red cat dominates with combination", "duration": 6 },
  { "prompt": "Blue cat clinches to recover", "duration": 5 },
  { "prompt": "Referee separates them", "duration": 3 },
  { "prompt": "Blue cat fires back aggressively", "duration": 6 },
  { "prompt": "Sweat flying with each punch, dramatic", "duration": 8 },
  { "prompt": "Round 2 ends, both exhausted", "duration": 5 },
  { "prompt": "Corners working urgently on fighters", "duration": 8 },

  // ROUND 3 - CLIMAX - Extended dramatic moments (8-12 seconds)
  {
    "prompt": "Final round bell, both stand with determination",
    "duration": 5
  },
  { "prompt": "Red cat charges forward aggressively", "duration": 5 },
  { "prompt": "Blue cat counters with perfect timing", "duration": 6 },
  { "prompt": "Epic punch exchange in slow motion", "duration": 10 },
  { "prompt": "Red cat corners blue cat, unleashing fury", "duration": 8 },
  { "prompt": "Blue cat survives, fires back desperately", "duration": 8 },
  { "prompt": "Both cats center ring, heavy breathing", "duration": 6 },
  { "prompt": "Red cat winds up massive right hook", "duration": 8 },
  {
    "prompt": "Perfect connection, blue cat's head snaps back",
    "duration": 10
  },
  { "prompt": "Blue cat's legs wobble, looks dazed", "duration": 8 },
  { "prompt": "Red cat moves in for finish", "duration": 5 },
  { "prompt": "Devastating final punch, full power", "duration": 10 },
  {
    "prompt": "Blue cat falling to canvas in extreme slow motion",
    "duration": 12
  },
  { "prompt": "Canvas impact, dramatic camera angle", "duration": 8 },
  { "prompt": "Referee rushes in, starts counting", "duration": 8 },
  { "prompt": "Count reaches ten, fight over", "duration": 10 },

  // VICTORY - Emotional moments (8-12 seconds)
  { "prompt": "Red cat explosion of joy, arms raised", "duration": 10 },
  { "prompt": "Medical team checking on blue cat", "duration": 8 },
  { "prompt": "Blue cat helped to feet, showing respect", "duration": 8 },
  { "prompt": "Referee raises red cat's arm in victory", "duration": 10 },
  { "prompt": "Red cat climbs corner post, crowd roaring", "duration": 10 },
  { "prompt": "Confetti falling from ceiling, celebration", "duration": 12 },
  { "prompt": "Championship belt brought into ring", "duration": 8 },
  {
    "prompt": "Belt wrapped around red cat's waist, champion pose",
    "duration": 10
  },
  { "prompt": "Both cats embrace showing sportsmanship", "duration": 10 },
  { "prompt": "Team rushes ring, group celebration", "duration": 8 },
  { "prompt": "Red cat lifted on shoulders with belt", "duration": 10 },
  { "prompt": "Camera flashes, photographers everywhere", "duration": 8 },
  { "prompt": "Red cat posing with belt, multiple angles", "duration": 12 },
  { "prompt": "Crowd on feet, waving flags, celebrating", "duration": 10 },
  { "prompt": "Replay of knockout in slow motion on screen", "duration": 12 },
  { "prompt": "Red cat victory speech with microphone", "duration": 10 },
  {
    "prompt": "Both cats arms raised together, mutual respect",
    "duration": 10
  },
  { "prompt": "Red cat kissing championship belt, emotional", "duration": 8 },
  {
    "prompt": "Wide shot of ring, confetti, crowd celebrating",
    "duration": 12
  },
  { "prompt": "Red cat exiting ring with belt, fans reaching", "duration": 8 },
  { "prompt": "Final shot: belt close-up with engraved name", "duration": 10 }
]
```

## Strategic Duration Tips:

### **Quick Cuts (3-4 seconds):**

- Establishing shots
- Fast action beats
- Crowd reactions
- Bell rings

### **Standard Shots (5-6 seconds):**

- Normal fighting action
- Movement sequences
- Dialogue/instructions

### **Extended Shots (8-12 seconds):**

- Dramatic moments
- Slow motion sequences
- Knockout impacts
- Emotional celebrations
- Key story beats

## Run It:

```bash
python story_video_generator.py \
  --story_file boxing_variable_duration.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --size 832*480 \
  --output_name boxing_10min_pro.mp4
```

**Note:** The `--segment_duration` flag is **ignored** when your JSON has duration fields!

```bash
# This flag does NOTHING if JSON has durations:
--segment_duration 5  # ← Ignored!

# Only matters if JSON scenes missing "duration":
--segment_duration 5  # ← Used as fallback
```

So **YES**, mix your durations freely for better cinematic pacing! 🎬

# storyfinal file

## Now Test It:

### Step 1: Quick test with simple prompt

```bash
python story_video_generator.py \
  --prompt "Two cats boxing" \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --duration 30 \
  --output_name test.mp4
```

### Step 2: If that works, try with JSON

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --output_name boxing_full.mp4
```

### 1. Save the script as `story_video_generator.py`

### 2. Create your story JSON (or use simple prompt)

**Simple 1-minute test:**

```bash
python story_video_generator.py \
  --prompt "Two anthropomorphic cats boxing" \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --duration 60 \
  --output_name test_1min.mp4
```

**Full 10-minute video with custom story:**

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --output_name boxing_10min.mp4
```

**High-quality with 5B model:**

```bash
python story_video_generator.py \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.2-TI2V-5B \
  --model ti2v-5B \
  --size 1280*704 \
  --convert_model_dtype \
  --output_name boxing_hq.mp4

```

# install ffmpeg

# apt-get install ffmpeg or brew install ffmpeg
