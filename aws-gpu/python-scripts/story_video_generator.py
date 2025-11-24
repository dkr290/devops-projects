#!/usr/bin/env python3
"""
Story-Driven Long Video Generator for Wan AI Models
Production-ready version with proper file handling
"""

import argparse
import json
import shutil
import subprocess
import time
from pathlib import Path
from typing import Dict, List, Optional


class StoryVideoGenerator:
    def __init__(
        self,
        model_type: str = "t2v-1.3B",
        ckpt_dir: str = "./Wan2.1-T2V-1.3B",
        size: str = "832*480",
        fps: int = 24,
        output_dir: str = "./story_video_output",
        sample_shift: float = 8.0,
        sample_guide_scale: float = 6.0,
        offload_model: bool = True,
        convert_model_dtype: bool = False,
        generation_dir: str = "./",  # Where generate.py saves files
    ):
        self.model_type = model_type
        self.ckpt_dir = ckpt_dir
        self.size = size
        self.fps = fps
        self.output_dir = Path(output_dir)
        self.sample_shift = sample_shift
        self.sample_guide_scale = sample_guide_scale
        self.offload_model = offload_model
        self.convert_model_dtype = convert_model_dtype
        self.generation_dir = Path(generation_dir)
        self.segments_dir = self.output_dir / "segments"

        self.output_dir.mkdir(exist_ok=True, parents=True)
        self.segments_dir.mkdir(exist_ok=True, parents=True)

    def create_story_timeline(
        self, main_prompt: str, duration: int, segment_duration: int = 5
    ) -> List[Dict]:
        """Create a timeline of scenes from a main prompt"""
        total_scenes = (duration + segment_duration - 1) // segment_duration

        timeline = []

        if "boxing" in main_prompt.lower() or "fight" in main_prompt.lower():
            base_subject = (
                main_prompt.split("fight")[0].strip()
                if "fight" in main_prompt
                else main_prompt
            )

            phases = [
                ("entering the ring, dramatic lighting, crowd cheering", 6),
                ("circling each other, testing jabs, defensive stance", 12),
                ("exchanging powerful punches, dynamic movement, intense action", 18),
                ("in fierce combat, sweat flying, powerful hooks and uppercuts", 12),
                ("final knockout punch, dramatic slow motion, victor celebration", 8),
                (
                    "victory celebration, crowd roaring, champion pose",
                    max(6, total_scenes - 62),
                ),
            ]

            for phase_desc, num_scenes in phases:
                for i in range(min(num_scenes, total_scenes - len(timeline))):
                    timeline.append(
                        {
                            "prompt": f"{base_subject} {phase_desc}",
                            "duration": segment_duration,
                            "seed_offset": len(timeline) * 100,
                        }
                    )
                if len(timeline) >= total_scenes:
                    break
        else:
            for i in range(total_scenes):
                timeline.append(
                    {
                        "prompt": main_prompt,
                        "duration": segment_duration,
                        "seed_offset": i * 100,
                    }
                )

        return timeline[:total_scenes]

    def load_story_from_file(self, story_file: str) -> List[Dict]:
        """Load story timeline from JSON file"""
        with open(story_file, "r") as f:
            timeline = json.load(f)

        for i, scene in enumerate(timeline):
            if "seed_offset" not in scene:
                scene["seed_offset"] = i * 100
            if "duration" not in scene:
                scene["duration"] = 5

        return timeline

    def find_latest_video(self, before_time: float) -> Optional[Path]:
        """Find the most recently generated video file"""
        patterns = [
            "*.mp4",
            "output*.mp4",
            "generated*.mp4",
            "sample*.mp4",
            "results/*.mp4",
            "outputs/*.mp4",
        ]

        latest_file = None
        latest_time = before_time

        for pattern in patterns:
            for filepath in self.generation_dir.glob(pattern):
                if filepath.stat().st_mtime > latest_time:
                    latest_time = filepath.stat().st_mtime
                    latest_file = filepath

        return latest_file

    def generate_segment(
        self,
        prompt: str,
        segment_idx: int,
        seed: int,
        image_path: Optional[str] = None,
    ) -> str:
        """Generate a single video segment"""

        output_file = self.segments_dir / f"segment_{segment_idx:04d}.mp4"

        # Record time before generation to find new file
        before_time = time.time()

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

        if self.offload_model:
            cmd.extend(["--offload_model", "True"])

        if self.convert_model_dtype:
            cmd.extend(["--convert_model_dtype"])

        if image_path and (
            "ti2v" in self.model_type.lower() or "vace" in self.model_type.lower()
        ):
            cmd.extend(["--image", image_path])

        print(f"\n{'='*60}")
        print(f"Scene {segment_idx + 1}")
        print(f"Prompt: {prompt[:70]}...")
        print(f"Seed: {seed}")
        print(f"{'='*60}\n")

        start_time = time.time()

        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(result.stdout)

            # Find the generated video file
            generated_file = self.find_latest_video(before_time)

            if generated_file and generated_file.exists():
                # Move it to our segments directory with proper naming
                shutil.move(str(generated_file), str(output_file))
                elapsed = time.time() - start_time
                print(f"✓ Completed in {elapsed:.2f}s")
                print(f"✓ Saved to: {output_file}")
                return str(output_file)
            else:
                # Try common default locations
                possible_paths = [
                    Path("output.mp4"),
                    Path("generated.mp4"),
                    Path(f"sample_{seed}.mp4"),
                ]

                for path in possible_paths:
                    if path.exists():
                        shutil.move(str(path), str(output_file))
                        print(f"✓ Found and moved: {path} -> {output_file}")
                        return str(output_file)

                raise FileNotFoundError(
                    f"Could not find generated video file for segment {segment_idx}"
                )

        except subprocess.CalledProcessError as e:
            print(f"✗ Error: {e}")
            print(f"STDERR: {e.stderr}")
            raise

    def extract_last_frame(self, video_path: str, output_path: str) -> Optional[str]:
        """Extract last frame from video for temporal consistency"""
        cmd = [
            "ffmpeg",
            "-y",
            "-sseof",
            "-1",
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
        except subprocess.CalledProcessError:
            return None

    def stitch_videos(self, segment_files: List[str], output_path: str):
        """Stitch video segments together"""
        concat_file = self.output_dir / "concat_list.txt"
        with open(concat_file, "w") as f:
            for seg in segment_files:
                abs_path = Path(seg).absolute()
                f.write(f"file '{abs_path}'\n")

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
        print("Stitching video segments...")
        print(f"{'='*60}\n")

        try:
            subprocess.run(cmd, check=True, capture_output=True, stderr=subprocess.PIPE)
            print(f"✓ Final video: {output_path}")
        except subprocess.CalledProcessError:
            print("✗ Stitching failed, trying re-encode method...")
            # Fallback: re-encode instead of copy (slower but more compatible)
            cmd = [
                "ffmpeg",
                "-y",
                "-f",
                "concat",
                "-safe",
                "0",
                "-i",
                str(concat_file),
                "-c:v",
                "libx264",
                "-preset",
                "fast",
                "-crf",
                "18",
                str(output_path),
            ]
            subprocess.run(cmd, check=True)
            print(f"✓ Final video (re-encoded): {output_path}")

    def generate_story_video(
        self,
        timeline: List[Dict],
        base_seed: int = 42,
        output_name: str = "story_video.mp4",
        use_temporal_consistency: bool = True,
    ) -> str:
        """Generate video from story timeline"""

        total_duration = sum(scene.get("duration", 5) for scene in timeline)

        print(f"\n{'#'*60}")
        print("# Story Video Generation")
        print(f"# Total scenes: {len(timeline)}")
        print(f"# Duration: {total_duration}s ({total_duration/60:.1f} min)")
        print(f"# Model: {self.model_type}")
        print(f"# Resolution: {self.size}")
        print(f"{'#'*60}\n")

        segment_files = []
        last_frame_path = None

        for i, scene in enumerate(timeline):
            seed = base_seed + scene.get("seed_offset", i * 100)

            image_input = None
            if use_temporal_consistency and last_frame_path and i > 0:
                if (
                    "ti2v" in self.model_type.lower()
                    or "vace" in self.model_type.lower()
                ):
                    image_input = last_frame_path

            try:
                segment_file = self.generate_segment(
                    prompt=scene["prompt"],
                    segment_idx=i,
                    seed=seed,
                    image_path=image_input,
                )

                segment_files.append(segment_file)

                if use_temporal_consistency and i < len(timeline) - 1:
                    last_frame_path = str(self.segments_dir / f"last_frame_{i:04d}.png")
                    self.extract_last_frame(segment_file, last_frame_path)

            except Exception as e:
                print(f"✗ Failed to generate scene {i+1}: {e}")
                print("Continuing with remaining scenes...")
                continue

        if not segment_files:
            raise RuntimeError("No segments were successfully generated!")

        final_output = self.output_dir / output_name
        self.stitch_videos(segment_files, str(final_output))

        return str(final_output)

    def cleanup(self, keep_segments: bool = False):
        """Clean up temporary files"""
        if not keep_segments:
            print("\nCleaning up temporary files...")
            cleaned = 0
            for item in self.segments_dir.glob("*"):
                if item.is_file():
                    item.unlink()
                    cleaned += 1
            if cleaned > 0:
                print(f"✓ Removed {cleaned} temporary files")


def main():
    parser = argparse.ArgumentParser(
        description="Generate story-driven long videos with Wan AI models",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Using JSON story file (RECOMMENDED)
  python %(prog)s --story_file boxing.json --ckpt_dir ./Wan2.1-T2V-1.3B
  
  # Using simple prompt with auto-story
  python %(prog)s --prompt "Two cats boxing" --ckpt_dir ./Wan2.1-T2V-1.3B --duration 300
  
  # High quality with 5B model
  python %(prog)s --story_file story.json --ckpt_dir ./Wan2.2-TI2V-5B --model ti2v-5B --size 1280*704 --convert_model_dtype
        """,
    )

    parser.add_argument(
        "--prompt", type=str, help="Main prompt (for auto story generation)"
    )
    parser.add_argument(
        "--story_file", type=str, help="JSON file with detailed scene timeline"
    )
    parser.add_argument(
        "--ckpt_dir", type=str, required=True, help="Model checkpoint directory"
    )
    parser.add_argument("--model", type=str, default="t2v-1.3B", help="Model type")
    parser.add_argument("--size", type=str, default="832*480", help="Video resolution")
    parser.add_argument(
        "--duration", type=int, default=300, help="Duration in seconds (with --prompt)"
    )
    parser.add_argument(
        "--segment_duration", type=int, default=5, help="Default segment duration"
    )
    parser.add_argument("--seed", type=int, default=42, help="Base random seed")
    parser.add_argument("--sample_shift", type=float, default=8.0)
    parser.add_argument("--sample_guide_scale", type=float, default=6.0)
    parser.add_argument("--output_dir", type=str, default="./story_video_output")
    parser.add_argument("--output_name", type=str, default="story_video.mp4")
    parser.add_argument(
        "--generation_dir",
        type=str,
        default="./",
        help="Directory where generate.py saves files",
    )
    parser.add_argument("--no_offload", action="store_true")
    parser.add_argument("--convert_model_dtype", action="store_true")
    parser.add_argument("--no_temporal_consistency", action="store_true")
    parser.add_argument(
        "--keep_segments", action="store_true", help="Keep individual segment files"
    )

    args = parser.parse_args()

    if not args.prompt and not args.story_file:
        parser.error("Must provide either --prompt or --story_file")

    print("\nConfiguration:")
    print(f"  Model: {args.model}")
    print(f"  Checkpoint: {args.ckpt_dir}")
    print(f"  Resolution: {args.size}")
    print(f"  Offload: {not args.no_offload}")
    print(f"  Convert dtype: {args.convert_model_dtype}\n")

    generator = StoryVideoGenerator(
        model_type=args.model,
        ckpt_dir=args.ckpt_dir,
        size=args.size,
        output_dir=args.output_dir,
        sample_shift=args.sample_shift,
        sample_guide_scale=args.sample_guide_scale,
        offload_model=not args.no_offload,
        convert_model_dtype=args.convert_model_dtype,
        generation_dir=args.generation_dir,
    )

    try:
        start_time = time.time()

        if args.story_file:
            timeline = generator.load_story_from_file(args.story_file)
        else:
            timeline = generator.create_story_timeline(
                args.prompt, args.duration, args.segment_duration
            )

        final_video = generator.generate_story_video(
            timeline=timeline,
            base_seed=args.seed,
            output_name=args.output_name,
            use_temporal_consistency=not args.no_temporal_consistency,
        )

        generator.cleanup(keep_segments=args.keep_segments)

        elapsed = time.time() - start_time
        total_duration = sum(s.get("duration", 5) for s in timeline)

        print(f"\n{'='*60}")
        print("✓ SUCCESS!")
        print(f"  Video: {final_video}")
        print(f"  Duration: {total_duration}s ({total_duration/60:.1f} min)")
        print(f"  Time taken: {elapsed:.1f}s ({elapsed/60:.1f} min)")
        print(f"  Scenes: {len(timeline)}")
        print(f"{'='*60}\n")

    except KeyboardInterrupt:
        print("\n\n✗ Interrupted by user")
    except Exception as e:
        print(f"\n{'='*60}")
        print(f"✗ ERROR: {e}")
        print(f"{'='*60}\n")
        import traceback

        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
