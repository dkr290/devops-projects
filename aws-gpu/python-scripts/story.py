#!/usr/bin/env python3
"""
Story-Driven Long Video Generator for Wan AI Models
Generates coherent long videos with scene progression and narrative flow
"""

import argparse
import json
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
        segment_seconds: int = 5,
        output_dir: str = "./story_video_output",
        sample_shift: float = 8.0,
        sample_guide_scale: float = 6.0,
        offload_model: bool = True,
        convert_model_dtype: bool = False,
    ):
        self.model_type = model_type
        self.ckpt_dir = ckpt_dir
        self.size = size
        self.fps = fps
        self.segment_seconds = segment_seconds
        self.output_dir = Path(output_dir)
        self.sample_shift = sample_shift
        self.sample_guide_scale = sample_guide_scale
        self.offload_model = offload_model
        self.convert_model_dtype = convert_model_dtype
        self.segments_dir = self.output_dir / "segments"

        self.output_dir.mkdir(exist_ok=True, parents=True)
        self.segments_dir.mkdir(exist_ok=True, parents=True)

    def create_story_timeline(self, main_prompt: str, duration: int) -> List[Dict]:
        """
        Create a timeline of scenes from a main prompt
        This is where you define the STORY PROGRESSION
        """
        scenes_per_minute = 12  # 5-second segments
        total_scenes = duration // self.segment_seconds

        # Parse the main prompt to create variations
        # This is a simple example - you can make this much more sophisticated

        timeline = []

        # Example: Boxing match progression
        if "boxing" in main_prompt.lower() or "fight" in main_prompt.lower():
            base_subject = (
                main_prompt.split("fight")[0].strip()
                if "fight" in main_prompt
                else main_prompt
            )

            # Opening scenes
            for i in range(min(6, total_scenes // 10)):
                timeline.append(
                    {
                        "prompt": f"{base_subject} entering the ring, dramatic lighting, crowd cheering",
                        "duration": self.segment_seconds,
                        "seed_offset": i * 100,
                    }
                )

            # Round 1 - Feeling each other out
            for i in range(min(12, total_scenes // 8)):
                timeline.append(
                    {
                        "prompt": f"{base_subject} circling each other, testing jabs, defensive stance",
                        "duration": self.segment_seconds,
                        "seed_offset": 1000 + i * 100,
                    }
                )

            # Round 2 - Action heats up
            for i in range(min(18, total_scenes // 6)):
                timeline.append(
                    {
                        "prompt": f"{base_subject} exchanging powerful punches, dynamic movement, intense action",
                        "duration": self.segment_seconds,
                        "seed_offset": 2000 + i * 100,
                    }
                )

            # Round 3 - Climax
            for i in range(min(12, total_scenes // 8)):
                timeline.append(
                    {
                        "prompt": f"{base_subject} in fierce combat, sweat flying, powerful hooks and uppercuts",
                        "duration": self.segment_seconds,
                        "seed_offset": 3000 + i * 100,
                    }
                )

            # Finish - One fighter winning
            for i in range(min(8, total_scenes // 10)):
                timeline.append(
                    {
                        "prompt": f"{base_subject} final knockout punch, dramatic slow motion, victor celebration",
                        "duration": self.segment_seconds,
                        "seed_offset": 4000 + i * 100,
                    }
                )

            # Victory celebration
            remaining = total_scenes - len(timeline)
            for i in range(remaining):
                timeline.append(
                    {
                        "prompt": f"{base_subject} victory celebration, crowd roaring, champion pose",
                        "duration": self.segment_seconds,
                        "seed_offset": 5000 + i * 100,
                    }
                )

        else:
            # Generic timeline - repeat main prompt with variations
            for i in range(total_scenes):
                timeline.append(
                    {
                        "prompt": main_prompt,
                        "duration": self.segment_seconds,
                        "seed_offset": i * 100,
                    }
                )

        return timeline

    def load_story_from_file(self, story_file: str) -> List[Dict]:
        """
        Load story timeline from JSON file
        Format:
        [
            {"prompt": "Scene 1 description", "duration": 5},
            {"prompt": "Scene 2 description", "duration": 8},
            ...
        ]
        """
        with open(story_file, "r") as f:
            timeline = json.load(f)

        # Add seed offsets if not present
        for i, scene in enumerate(timeline):
            if "seed_offset" not in scene:
                scene["seed_offset"] = i * 100
            if "duration" not in scene:
                scene["duration"] = self.segment_seconds

        return timeline

    def generate_segment(
        self,
        prompt: str,
        segment_idx: int,
        seed: int,
        image_path: Optional[str] = None,
    ) -> str:
        """Generate a single video segment"""

        output_file = self.segments_dir / f"segment_{segment_idx:04d}.mp4"

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
        print(f"Prompt: {prompt[:80]}...")
        print(f"Seed: {seed}")
        print(f"{'='*60}\n")

        start_time = time.time()

        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            elapsed = time.time() - start_time
            print(f"✓ Completed in {elapsed:.2f}s")
            return str(output_file)
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

        subprocess.run(cmd, check=True, capture_output=True, stderr=subprocess.PIPE)
        print(f"✓ Final video: {output_path}")

    def generate_story_video(
        self,
        timeline: List[Dict],
        base_seed: int = 42,
        output_name: str = "story_video.mp4",
        use_temporal_consistency: bool = True,
    ) -> str:
        """Generate video from story timeline"""

        total_duration = sum(scene["duration"] for scene in timeline)

        print(f"\n{'#'*60}")
        print("# Story Video Generation")
        print(f"# Total scenes: {len(timeline)}")
        print(f"# Duration: {total_duration}s ({total_duration/60:.1f} min)")
        print(f"# Model: {self.model_type}")
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

        final_output = self.output_dir / output_name
        self.stitch_videos(segment_files, str(final_output))

        return str(final_output)


def main():
    parser = argparse.ArgumentParser(
        description="Generate story-driven long videos with scene progression",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Auto-generate story from prompt (simple)
  python %(prog)s --prompt "Two cats boxing" --ckpt_dir ./Wan2.1-T2V-1.3B --duration 300
  
  # Load detailed story from JSON file
  python %(prog)s --story_file story.json --ckpt_dir ./Wan2.1-T2V-1.3B
  
Story JSON format:
  [
    {"prompt": "Opening scene", "duration": 5},
    {"prompt": "Action builds", "duration": 8},
    {"prompt": "Climax", "duration": 10}
  ]
        """,
    )

    parser.add_argument(
        "--prompt", type=str, help="Main prompt (for auto story generation)"
    )
    parser.add_argument(
        "--story_file", type=str, help="JSON file with detailed scene timeline"
    )
    parser.add_argument("--ckpt_dir", type=str, required=True)
    parser.add_argument("--model", type=str, default="t2v-1.3B")
    parser.add_argument("--size", type=str, default="832*480")
    parser.add_argument(
        "--duration",
        type=int,
        default=300,
        help="Duration in seconds (used with --prompt)",
    )
    parser.add_argument("--segment_duration", type=int, default=5)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--output_dir", type=str, default="./story_video_output")
    parser.add_argument("--output_name", type=str, default="story_video.mp4")
    parser.add_argument("--no_offload", action="store_true")
    parser.add_argument("--convert_model_dtype", action="store_true")
    parser.add_argument("--no_temporal_consistency", action="store_true")

    args = parser.parse_args()

    if not args.prompt and not args.story_file:
        parser.error("Must provide either --prompt or --story_file")

    generator = StoryVideoGenerator(
        model_type=args.model,
        ckpt_dir=args.ckpt_dir,
        size=args.size,
        segment_seconds=args.segment_duration,
        output_dir=args.output_dir,
        offload_model=not args.no_offload,
        convert_model_dtype=args.convert_model_dtype,
    )

    try:
        start_time = time.time()

        if args.story_file:
            timeline = generator.load_story_from_file(args.story_file)
        else:
            timeline = generator.create_story_timeline(args.prompt, args.duration)

        final_video = generator.generate_story_video(
            timeline=timeline,
            base_seed=args.seed,
            output_name=args.output_name,
            use_temporal_consistency=not args.no_temporal_consistency,
        )

        elapsed = time.time() - start_time
        print(f"\n{'='*60}")
        print("✓ SUCCESS!")
        print(f"  Video: {final_video}")
        print(f"  Time: {elapsed/60:.1f} min")
        print(f"{'='*60}\n")

    except Exception as e:
        print(f"✗ ERROR: {e}")
        raise


if __name__ == "__main__":
    main()
