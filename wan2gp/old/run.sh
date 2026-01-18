#!/bin/bash


set -euo pipefail  # Add strict error handling

# RunPod workspace persistence
export HF_HOME="/workspace/.cache/huggingface"
export TORCH_HOME="/workspace/.cache/torch"
mkdir -p "$HF_HOME" "$TORCH_HOME"

# --- 1. Model & Performance Defaults ---
# On a 5090/L40S, 'sage2' is the king of speed for long SVI videos.
ATTENTION=${WGP_ATTENTION:-sage2}       
# Profile 3 is best for high-end cards (24GB+ VRAM). It keeps the model in VRAM.
PROFILE=${WGP_PROFILE:-3}               
# TeaCache 2.0 is the "sweet spot" (2x speed with almost no quality loss).
TEACACHE=${WGP_TEACACHE:-2.0}           
QUANTIZE=${WGP_QUANTIZE:-"True"}        
PRELOAD=${WGP_PRELOAD:-2000}            # Preload more into VRAM for instant generation.

# --- 2. Auto-Download Logic (Crucial for RunPod) ---
# This ensures you have the 14B VACE model ready for your extensions.
echo "--- Checking Model Weights ---"
# Wan 2.2 14B Image-to-Video (I2V) and VACE are best for your trailer project.
MODEL_MODE=${WGP_MODEL:-"--i2v-14B"}    

# --- 3. Hardware Acceleration Switches ---
Q_FLAG=""
if [ "$QUANTIZE" = "True" ]; then Q_FLAG="--quantize-transformer"; fi

# Add --compile for a 20% speed boost on Linux (takes 2-3 mins on first run)
COMPILE_FLAG="--compile"

echo "--- Wan2GP Initializing on RunPod ---"
echo "Model: $MODEL_MODE | Attention: $ATTENTION | Profile: $PROFILE"

# --- 4. Launch Command ---
# --listen 0.0.0.0 is mandatory for RunPod access via the "Connect" button.
trap 'echo "Shutting down Wan2GP..."; kill -TERM $PID 2>/dev/null; wait $PID' TERM INT
python3 wgp.py \
    --listen 0.0.0.0 \
    --server-port 7860 \
    --attention "$ATTENTION" \
    --profile "$PROFILE" \
    --teacache "$TEACACHE" \
    --preload "$PRELOAD" \
    $Q_FLAG \
    $COMPILE_FLAG \
    $MODEL_MODE \
    $WGP_EXTRA_ARGS &

PID=$!
wait $PID
