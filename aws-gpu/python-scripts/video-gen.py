#!/usr/bin/env python3
"""
Long Video Generator for Wan AI Models
Generates extended videos by chunking and stitching segments with temporal consistency
"""

import argparse
import subprocess
from pathlib import Path
from typing import List


class LongVideoGenerator:
    def __init__(
        self,
        model_type: str = "t2v-1.3B",
        ckpt_dir: str = "./Wan2.1-T2V-1.3B",
        size: str = "832*480",
        fps: int = 24,
        segment_seconds: int = 5,
        total_duration: int = 600,  # 10 minutes
        output_dir: str = "./long_video_output",
        overlap_frames: int = 8,
    ):
        self.model_type = model_type
        self.ckpt_dir = ckpt_dir
        self.size = size
        self.fps = fps
        self.segment_seconds = segment_seconds
        self.total_duration = total_duration
        self.output_dir = Path(output_dir)
        self.overlap_frames = overlap_frames
        self.segments_dir = self.output_dir / "segments"

        # Create directories
        self.output_dir.mkdir(exist_ok=True)
        self.segments_dir.mkdir(exist_ok=True)

    def calculate_segments(self) -> int:
        """Calculate number of segments needed"""
        return (self.total_duration + self.segment_seconds - 1) // self.segment_seconds

    def generate_segment(
        self,
        prompt: str,
        segment_idx: int,
        seed: int,
        image_path: str = None,
        sample_shift: float = 8.0,
        sample_guide_scale: float = 6.0,
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
            "--offload_model",
            "True",
            "--t5_cpu",
            "--sample_shift",
            str(sample_shift),
            "--sample_guide_scale",
            str(sample_guide_scale),
            "--prompt",
            prompt,
            "--seed",
            str(seed),
            "--output",
            str(output_file),
        ]

        # Add model-specific options
        if "5B" in self.model_type:
            cmd.extend(["--convert_model_dtype"])

        # Add image for ti2v models
        if image_path and "ti2v" in self.model_type.lower():
            cmd.extend(["--image", image_path])

        print(f"\n{'='*60}")
        print(f"Generating segment {segment_idx + 1}")
        print(f"Command: {' '.join(cmd)}")
        print(f"{'='*60}\n")

        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(result.stdout)
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
            "-i",
            video_path,
            "-vf",
            "select='eq(n\,0)'",
            "-vframes",
            "1",
            output_path,
        ]
        subprocess.run(cmd, check=True, capture_output=True)
        return output_path

    def stitch_videos(self, segment_files: List[str], output_path: str):
        """Stitch video segments together with smooth transitions"""

        # Create concat file
        concat_file = self.output_dir / "concat_list.txt"
        with open(concat_file, "w") as f:
            for seg in segment_files:
                f.write(f"file '{seg}'\n")

        # Simple concatenation
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
            output_path,
        ]

        print(f"\n{'='*60}")
        print("Stitching segments together...")
        print(f"{'='*60}\n")

        subprocess.run(cmd, check=True)
        print(f"Final video saved to: {output_path}")

    def generate_long_video(
        self,
        prompt: str,
        base_seed: int = 42,
        output_name: str = "final_video.mp4",
        use_temporal_consistency: bool = True,
    ):
        """Generate long video by creating and stitching segments"""

        num_segments = self.calculate_segments()
        print(f"Generating {self.total_duration}s video in {num_segments} segments")
        print(f"Each segment: ~{self.segment_seconds}s at {self.fps} fps")

        segment_files = []
        last_frame_path = None

        for i in range(num_segments):
            # Calculate seed with variation for diversity
            seed = base_seed + i * 1000

            # For ti2v models, use last frame for consistency
            image_input = None
            if use_temporal_consistency and last_frame_path and i > 0:
                image_input = last_frame_path

            # Generate segment
            segment_file = self.generate_segment(
                prompt=prompt,
                segment_idx=i,
                seed=seed,
                image_path=image_input,
            )

            segment_files.append(segment_file)

            # Extract last frame for next segment
            if use_temporal_consistency and i < num_segments - 1:
                last_frame_path = str(self.segments_dir / f"last_frame_{i:04d}.png")
                self.extract_last_frame(segment_file, last_frame_path)

        # Stitch all segments
        final_output = self.output_dir / output_name
        self.stitch_videos(segment_files, str(final_output))

        # Cleanup
        self.cleanup(keep_segments=False)

        return str(final_output)

    def cleanup(self, keep_segments: bool = False):
        """Clean up temporary files"""
        if not keep_segments:
            print("Cleaning up segment files...")
            for item in self.segments_dir.glob("*"):
                if item.is_file():
                    item.unlink()


def main():
    parser = argparse.ArgumentParser(
        description="Generate long videos with Wan AI models"
    )
    parser.add_argument(
        "--prompt", type=str, required=True, help="Video generation prompt"
    )
    parser.add_argument(
        "--model",
        type=str,
        default="t2v-1.3B",
        choices=["t2v-1.3B", "ti2v-5B"],
        help="Model type",
    )
    parser.add_argument(
        "--ckpt_dir", type=str, required=True, help="Checkpoint directory"
    )
    parser.add_argument(
        "--size", type=str, default="832*480", help="Video resolution (W*H)"
    )
    parser.add_argument(
        "--duration", type=int, default=600, help="Total duration in seconds"
    )
    parser.add_argument(
        "--segment_duration", type=int, default=5, help="Each segment duration"
    )
    parser.add_argument("--fps", type=int, default=24, help="Frames per second")
    parser.add_argument("--seed", type=int, default=42, help="Base random seed")
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

    # Map model names to task names
    model_map = {"t2v-1.3B": "t2v-1.3B", "ti2v-5B": "ti2v-5B"}

    generator = LongVideoGenerator(
        model_type=model_map[args.model],
        ckpt_dir=args.ckpt_dir,
        size=args.size,
        fps=args.fps,
        segment_seconds=args.segment_duration,
        total_duration=args.duration,
        output_dir=args.output_dir,
    )

    try:
        final_video = generator.generate_long_video(
            prompt=args.prompt,
            base_seed=args.seed,
            output_name=args.output_name,
            use_temporal_consistency=not args.no_temporal_consistency,
        )
        print(f"\n{'='*60}")
        print(f"SUCCESS! Video generated: {final_video}")
        print(f"{'='*60}\n")
    except Exception as e:
        print(f"Error: {e}")
        raise


if __name__ == "__main__":
    main()
