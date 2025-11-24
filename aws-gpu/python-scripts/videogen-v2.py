#!/usr/bin/env python3
"""
Long Video Generator for Wan AI Models
Generates extended videos of any duration by chunking and stitching segments
Supports all Wan models: T2V-1.3B, TI2V-5B, VACE-1.3B, etc.
"""

import argparse
import subprocess
import time
from pathlib import Path
from typing import List, Optional


class LongVideoGenerator:
    def __init__(
        self,
        model_type: str = "t2v-1.3B",
        ckpt_dir: str = "./Wan2.1-T2V-1.3B",
        size: str = "832*480",
        fps: int = 24,
        segment_seconds: int = 5,
        total_duration: int = 600,
        output_dir: str = "./long_video_output",
        sample_shift: float = 8.0,
        sample_guide_scale: float = 6.0,
        offload_model: bool = True,
        convert_model_dtype: bool = False,
        use_t5_cpu: bool = False,
    ):
        self.model_type = model_type
        self.ckpt_dir = ckpt_dir
        self.size = size
        self.fps = fps
        self.segment_seconds = segment_seconds
        self.total_duration = total_duration
        self.output_dir = Path(output_dir)
        self.sample_shift = sample_shift
        self.sample_guide_scale = sample_guide_scale
        self.offload_model = offload_model
        self.convert_model_dtype = convert_model_dtype
        self.use_t5_cpu = use_t5_cpu
        self.segments_dir = self.output_dir / "segments"

        # Create directories
        self.output_dir.mkdir(exist_ok=True, parents=True)
        self.segments_dir.mkdir(exist_ok=True, parents=True)

    def calculate_segments(self) -> int:
        """Calculate number of segments needed"""
        return (self.total_duration + self.segment_seconds - 1) // self.segment_seconds

    def generate_segment(
        self,
        prompt: str,
        segment_idx: int,
        seed: int,
        image_path: Optional[str] = None,
    ) -> str:
        """Generate a single video segment"""

        output_file = self.segments_dir / f"segment_{segment_idx:04d}.mp4"

        # Base command
        cmd = [
            "python",
            "generate.py",
            "--task",
            self.model_type,
            "--size",
            self.size,
            "--ckpt_dir",
            self.ckpt_dir,
            "--sample_shift",
            str(self.sample_shift),
            "--sample_guide_scale",
            str(self.sample_guide_scale),
            "--prompt",
            prompt,
            "--seed",
            str(seed),
        ]

        # Optional flags
        if self.offload_model:
            cmd.extend(["--offload_model", "True"])

        if self.convert_model_dtype:
            cmd.extend(["--convert_model_dtype"])

        if self.use_t5_cpu:
            cmd.extend(["--t5_cpu"])

        # Add image for ti2v/vace models
        if image_path and (
            "ti2v" in self.model_type.lower() or "vace" in self.model_type.lower()
        ):
            cmd.extend(["--image", image_path])

        # Add output path if generate.py supports it
        # Otherwise, you'll need to move the file after generation

        print(f"\n{'='*60}")
        print(f"Generating segment {segment_idx + 1}/{self.calculate_segments()}")
        print(f"Seed: {seed}")
        if image_path:
            print(f"Using reference image: {image_path}")
        print(f"Command: {' '.join(cmd)}")
        print(f"{'='*60}\n")

        start_time = time.time()

        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(result.stdout)

            # If generate.py doesn't support --output, find the generated file
            # and move it to our segments directory
            # This assumes generate.py saves to current directory or a predictable location
            # Adjust this based on actual generate.py behavior

            elapsed = time.time() - start_time
            print(f"Segment {segment_idx + 1} completed in {elapsed:.2f}s")

            return str(output_file)
        except subprocess.CalledProcessError as e:
            print(f"Error generating segment {segment_idx}: {e}")
            print(f"STDERR: {e.stderr}")
            raise

    def extract_last_frame(self, video_path: str, output_path: str) -> str:
        """Extract last frame from video for temporal consistency"""
        cmd = [
            "ffmpeg",
            "-y",
            "-sseof",
            "-1",  # Seek to 1 second before end
            "-i",
            video_path,
            "-update",
            "1",
            "-q:v",
            "1",
            output_path,
        ]
        try:
            subprocess.run(cmd, check=True, capture_output=True, stderr=subprocess.PIPE)
            return output_path
        except subprocess.CalledProcessError as e:
            print(f"Warning: Could not extract last frame: {e}")
            return None

    def stitch_videos(self, segment_files: List[str], output_path: str):
        """Stitch video segments together"""

        # Create concat file
        concat_file = self.output_dir / "concat_list.txt"
        with open(concat_file, "w") as f:
            for seg in segment_files:
                # Use absolute paths for safety
                abs_path = Path(seg).absolute()
                f.write(f"file '{abs_path}'\n")

        # Concatenate videos
        cmd = [
            "ffmpeg",
            "-y",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(concat_file),
            "-c",
            "copy",
            str(output_path),
        ]

        print(f"\n{'='*60}")
        print("Stitching segments together...")
        print(f"Total segments: {len(segment_files)}")
        print(f"{'='*60}\n")

        try:
            subprocess.run(cmd, check=True, capture_output=True, stderr=subprocess.PIPE)
            print(f"✓ Final video saved to: {output_path}")
        except subprocess.CalledProcessError as e:
            print(f"Error stitching videos: {e}")
            print(f"STDERR: {e.stderr.decode() if e.stderr else 'N/A'}")
            raise

    def generate_long_video(
        self,
        prompt: str,
        base_seed: int = 42,
        output_name: str = "final_video.mp4",
        use_temporal_consistency: bool = True,
    ) -> str:
        """Generate long video by creating and stitching segments"""

        num_segments = self.calculate_segments()
        total_mins = self.total_duration / 60

        print(f"\n{'#'*60}")
        print("# Long Video Generation")
        print(f"# Duration: {self.total_duration}s ({total_mins:.1f} minutes)")
        print(f"# Segments: {num_segments} x {self.segment_seconds}s")
        print(f"# Resolution: {self.size}")
        print(f"# Model: {self.model_type}")
        print(
            f"# Temporal Consistency: {'Enabled' if use_temporal_consistency else 'Disabled'}"
        )
        print(f"{'#'*60}\n")

        segment_files = []
        last_frame_path = None

        for i in range(num_segments):
            # Calculate seed with variation for diversity
            seed = base_seed + i * 1000

            # For ti2v/vace models, use last frame for consistency
            image_input = None
            if use_temporal_consistency and last_frame_path and i > 0:
                if (
                    "ti2v" in self.model_type.lower()
                    or "vace" in self.model_type.lower()
                ):
                    image_input = last_frame_path

            # Generate segment
            segment_file = self.generate_segment(
                prompt=prompt,
                segment_idx=i,
                seed=seed,
                image_path=image_input,
            )

            # Verify segment was created
            if not Path(segment_file).exists():
                # Try to find the generated file
                print(f"Warning: Expected segment not found at {segment_file}")
                print("Searching for generated video...")
                # Add logic here to find the actual generated file
                # This depends on how generate.py names its outputs

            segment_files.append(segment_file)

            # Extract last frame for next segment
            if use_temporal_consistency and i < num_segments - 1:
                last_frame_path = str(self.segments_dir / f"last_frame_{i:04d}.png")
                self.extract_last_frame(segment_file, last_frame_path)

        # Stitch all segments
        final_output = self.output_dir / output_name
        self.stitch_videos(segment_files, str(final_output))

        return str(final_output)

    def cleanup(self, keep_segments: bool = False):
        """Clean up temporary files"""
        if not keep_segments:
            print("\nCleaning up segment files...")
            cleaned = 0
            for item in self.segments_dir.glob("*"):
                if item.is_file():
                    item.unlink()
                    cleaned += 1
            print(f"✓ Removed {cleaned} temporary files")


def main():
    parser = argparse.ArgumentParser(
        description="Generate long videos with Wan AI models (any duration, any model)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""

Examples:
  # 10-minute video with T2V-1.3B
  python %(prog)s --prompt "Your prompt" --model t2v-1.3B --ckpt_dir ./Wan2.1-T2V-1.3B --duration 600

  # 30-minute high-quality video with TI2V-5B
  python %(prog)s --prompt "Your prompt" --model ti2v-5B --ckpt_dir ./Wan2.2-TI2V-5B --size 1280*704 --duration 1800

  # 1-hour video with VACE
  python %(prog)s --prompt "Your prompt" --model vace-1.3B --ckpt_dir ./Wan2.1-VACE-1.3B --duration 3600 --segment_duration 8
        """,
    )

    # Required arguments
    parser.add_argument(
        "--prompt", type=str, required=True, help="Video generation prompt"
    )
    parser.add_argument(
        "--ckpt_dir", type=str, required=True, help="Checkpoint directory"
    )

    # Model configuration
    parser.add_argument(
        "--model",
        type=str,
        default="t2v-1.3B",
        help="Model task name (e.g., t2v-1.3B, ti2v-5B, vace-1.3B)",
    )
    parser.add_argument(
        "--size", type=str, default="832*480", help="Video resolution (W*H)"
    )

    # Duration settings
    parser.add_argument(
        "--duration",
        type=int,
        default=600,
        help="Total duration in seconds (default: 600 = 10 min)",
    )
    parser.add_argument(
        "--segment_duration",
        type=int,
        default=5,
        help="Each segment duration in seconds",
    )
    parser.add_argument("--fps", type=int, default=24, help="Frames per second")

    # Generation parameters
    parser.add_argument("--seed", type=int, default=42, help="Base random seed")
    parser.add_argument(
        "--sample_shift", type=float, default=8.0, help="Sample shift parameter"
    )
    parser.add_argument(
        "--sample_guide_scale", type=float, default=6.0, help="Sample guidance scale"
    )

    # Model optimization flags
    parser.add_argument(
        "--no_offload",
        action="store_true",
        help="Disable model offloading (requires more VRAM)",
    )
    parser.add_argument(
        "--convert_model_dtype",
        action="store_true",
        help="Convert model dtype (for 5B models)",
    )
    parser.add_argument(
        "--t5_cpu", action="store_true", help="Use T5 on CPU (slower but saves VRAM)"
    )

    # Output settings
    parser.add_argument(
        "--output_dir", type=str, default="./long_video_output", help="Output directory"
    )
    parser.add_argument(
        "--output_name",
        type=str,
        default="final_video.mp4",
        help="Final video filename",
    )
    parser.add_argument(
        "--keep_segments", action="store_true", help="Keep individual segment files"
    )
    parser.add_argument(
        "--no_temporal_consistency",
        action="store_true",
        help="Disable temporal consistency between segments",
    )

    args = parser.parse_args()

    # Display configuration
    print("\nConfiguration:")
    print(f"  Model: {args.model}")
    print(f"  Checkpoint: {args.ckpt_dir}")
    print(f"  Duration: {args.duration}s ({args.duration/60:.1f} min)")
    print(f"  Resolution: {args.size}")
    print(f"  Segment length: {args.segment_duration}s")
    print(f"  Offload model: {not args.no_offload}")
    print(f"  Convert dtype: {args.convert_model_dtype}")
    print(f"  T5 on CPU: {args.t5_cpu}")

    generator = LongVideoGenerator(
        model_type=args.model,
        ckpt_dir=args.ckpt_dir,
        size=args.size,
        fps=args.fps,
        segment_seconds=args.segment_duration,
        total_duration=args.duration,
        output_dir=args.output_dir,
        sample_shift=args.sample_shift,
        sample_guide_scale=args.sample_guide_scale,
        offload_model=not args.no_offload,
        convert_model_dtype=args.convert_model_dtype,
        use_t5_cpu=args.t5_cpu,
    )

    try:
        start_time = time.time()

        final_video = generator.generate_long_video(
            prompt=args.prompt,
            base_seed=args.seed,
            output_name=args.output_name,
            use_temporal_consistency=not args.no_temporal_consistency,
        )

        # Cleanup unless keeping segments
        generator.cleanup(keep_segments=args.keep_segments)

        elapsed = time.time() - start_time
        print(f"\n{'='*60}")
        print("✓ SUCCESS!")
        print(f"  Video: {final_video}")
        print(f"  Duration: {args.duration}s ({args.duration/60:.1f} min)")
        print(f"  Time taken: {elapsed:.1f}s ({elapsed/60:.1f} min)")
        print(f"{'='*60}\n")

    except Exception as e:
        print(f"\n{'='*60}")
        print(f"✗ ERROR: {e}")
        print(f"{'='*60}\n")
        raise


if __name__ == "__main__":
    main()
