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
