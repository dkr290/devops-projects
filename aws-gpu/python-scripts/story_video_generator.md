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

## ✅ Now it should work with NO errors!

The key fixes:

- ✅ Automatically finds generated video files
- ✅ Handles different output locations
- ✅ Proper error handling
- ✅ Continues if one scene fails
- ✅ Fallback re-encoding if stitching fails

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
