\*Key differences from Python:\*\*

- Struct-based instead of class-based
- Explicit error handling instead of exceptions
- `flag` package for CLI args instead of `argparse`
- `os/exec` for subprocess execution
- `filepath` package for path operations
- Simpler method signatures (Go doesn't have default parameters)

**Usage:**

```bash
go run story_video_generator.go --story_file boxing.json --ckpt_dir ./Wan2.1-T2V-1.3B
```

### Step 1: Simple prompt mode (auto-generates story)

```bash
go run story_video_generator.go \
  --prompt "Two cats boxing" \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --duration 30 \
  --output_name test.mp4
```

### Step 2: JSON file mode (detailed scene control)

```bash
go run story_video_generator.go \
  --story_file boxing_10min.json \
  --ckpt_dir ./Wan2.1-T2V-1.3B \
  --model t2v-1.3B \
  --output_name boxing_full.mp4
```

### Example JSON format:

**Simple example (`boxing_short.json`):**

```json
[
  {
    "prompt": "Two cats entering boxing ring, dramatic lighting",
    "duration": 5,
    "seed_offset": 0
  },
  {
    "prompt": "Two cats circling each other, testing jabs",
    "duration": 5,
    "seed_offset": 100
  },
  {
    "prompt": "Two cats exchanging punches, intense action",
    "duration": 5,
    "seed_offset": 200
  }
]
```

**Longer example (`boxing_10min.json`):**

```json
[
  {
    "prompt": "Two anthropomorphic cats entering boxing ring, dramatic spotlight, crowd cheering",
    "duration": 10
  },
  {
    "prompt": "Two cats in boxing stance, circling cautiously, testing jabs",
    "duration": 15
  },
  {
    "prompt": "Cats exchanging powerful punches, dynamic movement, sweat flying",
    "duration": 20
  },
  {
    "prompt": "Intense boxing match, hooks and uppercuts, crowd roaring",
    "duration": 25
  },
  {
    "prompt": "Final knockout punch in slow motion, dramatic lighting",
    "duration": 15
  },
  {
    "prompt": "Victory celebration, champion cat with raised paws",
    "duration": 15
  }
]
```

### Or compile and run:

```bash
# Compile once
go build -o story-video-gen story_video_generator.go

# Then run
./story-video-gen --prompt "Two cats boxing" --ckpt_dir ./Wan2.1-T2V-1.3B --duration 30

./story-video-gen --story_file boxing_10min.json --ckpt_dir ./Wan2.1-T2V-1.3B
```

The Go version supports:

- ✅ Simple prompt auto-story generation
- ✅ JSON file with custom scenes
- ✅ All the same flags as Python version
- ✅ Temporal consistency (using last frame as next input)
- ✅ Video stitching with FFmpeg
- ✅ Progress logging
- ✅ Error handling and cleanup

**Note:** The JSON can omit `seed_offset` and `duration` - they'll default to `i*100` and `5` respectively.
