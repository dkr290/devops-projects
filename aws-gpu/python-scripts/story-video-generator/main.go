package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// Scene represents a single scene in the story timeline
type Scene struct {
	Prompt     string `json:"prompt"`
	Duration   int    `json:"duration"`
	SeedOffset int    `json:"seed_offset"`
}

// StoryVideoGenerator handles video generation from story timelines
type StoryVideoGenerator struct {
	ModelType         string
	CkptDir           string
	Size              string
	FPS               int
	OutputDir         string
	SampleShift       float64
	SampleGuideScale  float64
	OffloadModel      bool
	ConvertModelDtype bool
	GenerationDir     string
	SegmentsDir       string
}

// NewStoryVideoGenerator creates a new generator with default values
func NewStoryVideoGenerator(config GeneratorConfig) (*StoryVideoGenerator, error) {
	g := &StoryVideoGenerator{
		ModelType:         config.ModelType,
		CkptDir:           config.CkptDir,
		Size:              config.Size,
		FPS:               config.FPS,
		OutputDir:         config.OutputDir,
		SampleShift:       config.SampleShift,
		SampleGuideScale:  config.SampleGuideScale,
		OffloadModel:      config.OffloadModel,
		ConvertModelDtype: config.ConvertModelDtype,
		GenerationDir:     config.GenerationDir,
	}

	g.SegmentsDir = filepath.Join(g.OutputDir, "segments")

	// Create directories
	if err := os.MkdirAll(g.OutputDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create output dir: %w", err)
	}
	if err := os.MkdirAll(g.SegmentsDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create segments dir: %w", err)
	}

	return g, nil
}

type GeneratorConfig struct {
	ModelType         string
	CkptDir           string
	Size              string
	FPS               int
	OutputDir         string
	SampleShift       float64
	SampleGuideScale  float64
	OffloadModel      bool
	ConvertModelDtype bool
	GenerationDir     string
}

// CreateStoryTimeline generates a timeline from a main prompt
func (g *StoryVideoGenerator) CreateStoryTimeline(
	mainPrompt string,
	duration, segmentDuration int,
) []Scene {
	totalScenes := (duration + segmentDuration - 1) / segmentDuration
	timeline := make([]Scene, 0, totalScenes)

	promptLower := strings.ToLower(mainPrompt)
	if strings.Contains(promptLower, "boxing") || strings.Contains(promptLower, "fight") {
		baseSubject := mainPrompt
		if strings.Contains(mainPrompt, "fight") {
			parts := strings.Split(mainPrompt, "fight")
			baseSubject = strings.TrimSpace(parts[0])
		}

		phases := []struct {
			desc      string
			numScenes int
		}{
			{"entering the ring, dramatic lighting, crowd cheering", 6},
			{"circling each other, testing jabs, defensive stance", 12},
			{"exchanging powerful punches, dynamic movement, intense action", 18},
			{"in fierce combat, sweat flying, powerful hooks and uppercuts", 12},
			{"final knockout punch, dramatic slow motion, victor celebration", 8},
			{"victory celebration, crowd roaring, champion pose", max(6, totalScenes-62)},
		}

		for _, phase := range phases {
			numToAdd := min(phase.numScenes, totalScenes-len(timeline))
			for i := 0; i < numToAdd; i++ {
				timeline = append(timeline, Scene{
					Prompt:     fmt.Sprintf("%s %s", baseSubject, phase.desc),
					Duration:   segmentDuration,
					SeedOffset: len(timeline) * 100,
				})
			}
			if len(timeline) >= totalScenes {
				break
			}
		}
	} else {
		for i := 0; i < totalScenes; i++ {
			timeline = append(timeline, Scene{
				Prompt:     mainPrompt,
				Duration:   segmentDuration,
				SeedOffset: i * 100,
			})
		}
	}

	return timeline[:min(len(timeline), totalScenes)]
}

// LoadStoryFromFile loads story timeline from JSON file
func (g *StoryVideoGenerator) LoadStoryFromFile(storyFile string) ([]Scene, error) {
	data, err := os.ReadFile(storyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read story file: %w", err)
	}

	var timeline []Scene
	if err := json.Unmarshal(data, &timeline); err != nil {
		return nil, fmt.Errorf("failed to parse story file: %w", err)
	}

	// Set defaults
	for i := range timeline {
		if timeline[i].SeedOffset == 0 {
			timeline[i].SeedOffset = i * 100
		}
		if timeline[i].Duration == 0 {
			timeline[i].Duration = 5
		}
	}

	return timeline, nil
}

// FindLatestVideo finds the most recently generated video file
func (g *StoryVideoGenerator) FindLatestVideo(beforeTime time.Time) (string, error) {
	patterns := []string{
		"*.mp4",
		"output*.mp4",
		"generated*.mp4",
		"sample*.mp4",
		"results/*.mp4",
		"outputs/*.mp4",
	}

	var latestFile string
	latestTime := beforeTime

	for _, pattern := range patterns {
		matches, _ := filepath.Glob(filepath.Join(g.GenerationDir, pattern))
		for _, match := range matches {
			info, err := os.Stat(match)
			if err != nil {
				continue
			}
			if info.ModTime().After(latestTime) {
				latestTime = info.ModTime()
				latestFile = match
			}
		}
	}

	if latestFile == "" {
		return "", fmt.Errorf("no video file found")
	}

	return latestFile, nil
}

// GenerateSegment generates a single video segment
func (g *StoryVideoGenerator) GenerateSegment(
	prompt string,
	segmentIdx, seed int,
	imagePath string,
) (string, error) {
	outputFile := filepath.Join(g.SegmentsDir, fmt.Sprintf("segment_%04d.mp4", segmentIdx))

	beforeTime := time.Now()

	args := []string{
		"generate.py",
		"--task", g.ModelType,
		"--size", g.Size,
		"--ckpt_dir", g.CkptDir,
		"--sample_shift", fmt.Sprintf("%.1f", g.SampleShift),
		"--sample_guide_scale", fmt.Sprintf("%.1f", g.SampleGuideScale),
		"--prompt", prompt,
		"--seed", fmt.Sprintf("%d", seed),
	}

	if g.OffloadModel {
		args = append(args, "--offload_model", "True")
	}

	if g.ConvertModelDtype {
		args = append(args, "--convert_model_dtype")
	}

	modelLower := strings.ToLower(g.ModelType)
	if imagePath != "" &&
		(strings.Contains(modelLower, "ti2v") || strings.Contains(modelLower, "vace")) {
		args = append(args, "--image", imagePath)
	}

	fmt.Println(strings.Repeat("=", 60))
	fmt.Printf("Scene %d\n", segmentIdx+1)
	promptPreview := prompt
	if len(prompt) > 70 {
		promptPreview = prompt[:70] + "..."
	}
	fmt.Printf("Prompt: %s\n", promptPreview)
	fmt.Printf("Seed: %d\n", seed)
	fmt.Println(strings.Repeat("=", 60))

	startTime := time.Now()

	cmd := exec.Command("python", args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("generation failed: %w\nOutput: %s", err, string(output))
	}
	fmt.Print(string(output))

	// Find generated video
	generatedFile, err := g.FindLatestVideo(beforeTime)
	if err == nil && generatedFile != "" {
		if err := os.Rename(generatedFile, outputFile); err != nil {
			return "", fmt.Errorf("failed to move generated file: %w", err)
		}
		elapsed := time.Since(startTime)
		fmt.Printf("✓ Completed in %.2fs\n", elapsed.Seconds())
		fmt.Printf("✓ Saved to: %s\n", outputFile)
		return outputFile, nil
	}

	// Try common default locations
	possiblePaths := []string{
		"output.mp4",
		"generated.mp4",
		fmt.Sprintf("sample_%d.mp4", seed),
	}

	for _, path := range possiblePaths {
		if _, err := os.Stat(path); err == nil {
			if err := os.Rename(path, outputFile); err != nil {
				return "", err
			}
			fmt.Printf("✓ Found and moved: %s -> %s\n", path, outputFile)
			return outputFile, nil
		}
	}

	return "", fmt.Errorf("could not find generated video file for segment %d", segmentIdx)
}

// ExtractLastFrame extracts last frame from video for temporal consistency
func (g *StoryVideoGenerator) ExtractLastFrame(videoPath, outputPath string) error {
	cmd := exec.Command("ffmpeg",
		"-y",
		"-sseof", "-1",
		"-i", videoPath,
		"-update", "1",
		"-q:v", "1",
		outputPath,
	)
	return cmd.Run()
}

// StitchVideos stitches video segments together
func (g *StoryVideoGenerator) StitchVideos(segmentFiles []string, outputPath string) error {
	concatFile := filepath.Join(g.OutputDir, "concat_list.txt")

	// Create concat file
	var content strings.Builder
	for _, seg := range segmentFiles {
		absPath, _ := filepath.Abs(seg)
		content.WriteString(fmt.Sprintf("file '%s'\n", absPath))
	}

	if err := os.WriteFile(concatFile, []byte(content.String()), 0644); err != nil {
		return fmt.Errorf("failed to create concat file: %w", err)
	}

	fmt.Println(strings.Repeat("=", 60))
	fmt.Println("Stitching video segments...")
	fmt.Println(strings.Repeat("=", 60))

	cmd := exec.Command("ffmpeg",
		"-y",
		"-f", "concat",
		"-safe", "0",
		"-i", concatFile,
		"-c", "copy",
		outputPath,
	)

	if err := cmd.Run(); err != nil {
		fmt.Println("✗ Stitching failed, trying re-encode method...")
		// Fallback: re-encode
		cmd = exec.Command("ffmpeg",
			"-y",
			"-f", "concat",
			"-safe", "0",
			"-i", concatFile,
			"-c:v", "libx264",
			"-preset", "fast",
			"-crf", "18",
			outputPath,
		)
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("stitching failed: %w", err)
		}
		fmt.Printf("✓ Final video (re-encoded): %s\n", outputPath)
		return nil
	}

	fmt.Printf("✓ Final video: %s\n", outputPath)
	return nil
}

// GenerateStoryVideo generates video from story timeline
func (g *StoryVideoGenerator) GenerateStoryVideo(
	timeline []Scene,
	baseSeed int,
	outputName string,
	useTemporalConsistency bool,
) (string, error) {
	totalDuration := 0
	for _, scene := range timeline {
		totalDuration += scene.Duration
	}

	fmt.Println(strings.Repeat("#", 60))
	fmt.Println("# Story Video Generation")
	fmt.Printf("# Total scenes: %d\n", len(timeline))
	fmt.Printf("# Duration: %ds (%.1f min)\n", totalDuration, float64(totalDuration)/60)
	fmt.Printf("# Model: %s\n", g.ModelType)
	fmt.Printf("# Resolution: %s\n", g.Size)
	fmt.Println(strings.Repeat("#", 60))

	segmentFiles := make([]string, 0, len(timeline))
	var lastFramePath string

	for i, scene := range timeline {
		seed := baseSeed + scene.SeedOffset

		imageInput := ""
		if useTemporalConsistency && lastFramePath != "" && i > 0 {
			modelLower := strings.ToLower(g.ModelType)
			if strings.Contains(modelLower, "ti2v") || strings.Contains(modelLower, "vace") {
				imageInput = lastFramePath
			}
		}

		segmentFile, err := g.GenerateSegment(scene.Prompt, i, seed, imageInput)
		if err != nil {
			fmt.Printf("✗ Failed to generate scene %d: %v\n", i+1, err)
			fmt.Println("Continuing with remaining scenes...")
			continue
		}

		segmentFiles = append(segmentFiles, segmentFile)

		if useTemporalConsistency && i < len(timeline)-1 {
			lastFramePath = filepath.Join(g.SegmentsDir, fmt.Sprintf("last_frame_%04d.png", i))
			_ = g.ExtractLastFrame(segmentFile, lastFramePath)
		}
	}

	if len(segmentFiles) == 0 {
		return "", fmt.Errorf("no segments were successfully generated")
	}

	finalOutput := filepath.Join(g.OutputDir, outputName)
	if err := g.StitchVideos(segmentFiles, finalOutput); err != nil {
		return "", err
	}

	return finalOutput, nil
}

// Cleanup removes temporary files
func (g *StoryVideoGenerator) Cleanup(keepSegments bool) error {
	if keepSegments {
		return nil
	}

	fmt.Println("\nCleaning up temporary files...")
	cleaned := 0

	entries, err := os.ReadDir(g.SegmentsDir)
	if err != nil {
		return err
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			path := filepath.Join(g.SegmentsDir, entry.Name())
			if err := os.Remove(path); err == nil {
				cleaned++
			}
		}
	}

	if cleaned > 0 {
		fmt.Printf("✓ Removed %d temporary files\n", cleaned)
	}

	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func main() {
	// Command line flags
	prompt := flag.String("prompt", "", "Main prompt (for auto story generation)")
	storyFile := flag.String("story_file", "", "JSON file with detailed scene timeline")
	ckptDir := flag.String("ckpt_dir", "", "Model checkpoint directory (required)")
	model := flag.String("model", "t2v-1.3B", "Model type")
	size := flag.String("size", "832*480", "Video resolution")
	duration := flag.Int("duration", 300, "Duration in seconds (with --prompt)")
	segmentDuration := flag.Int("segment_duration", 5, "Default segment duration")
	seed := flag.Int("seed", 42, "Base random seed")
	sampleShift := flag.Float64("sample_shift", 8.0, "Sample shift")
	sampleGuideScale := flag.Float64("sample_guide_scale", 6.0, "Sample guide scale")
	outputDir := flag.String("output_dir", "./story_video_output", "Output directory")
	outputName := flag.String("output_name", "story_video.mp4", "Output filename")
	generationDir := flag.String("generation_dir", "./", "Directory where generate.py saves files")
	noOffload := flag.Bool("no_offload", false, "Disable model offloading")
	convertModelDtype := flag.Bool("convert_model_dtype", false, "Convert model dtype")
	noTemporalConsistency := flag.Bool(
		"no_temporal_consistency",
		false,
		"Disable temporal consistency",
	)
	keepSegments := flag.Bool("keep_segments", false, "Keep individual segment files")

	flag.Parse()

	if *prompt == "" && *storyFile == "" {
		fmt.Println("Error: Must provide either --prompt or --story_file")
		flag.Usage()
		os.Exit(1)
	}

	if *ckptDir == "" {
		fmt.Println("Error: --ckpt_dir is required")
		flag.Usage()
		os.Exit(1)
	}

	fmt.Println("\nConfiguration:")
	fmt.Printf("  Model: %s\n", *model)
	fmt.Printf("  Checkpoint: %s\n", *ckptDir)
	fmt.Printf("  Resolution: %s\n", *size)
	fmt.Printf("  Offload: %t\n", !*noOffload)
	fmt.Printf("  Convert dtype: %t\n\n", *convertModelDtype)

	config := GeneratorConfig{
		ModelType:         *model,
		CkptDir:           *ckptDir,
		Size:              *size,
		FPS:               24,
		OutputDir:         *outputDir,
		SampleShift:       *sampleShift,
		SampleGuideScale:  *sampleGuideScale,
		OffloadModel:      !*noOffload,
		ConvertModelDtype: *convertModelDtype,
		GenerationDir:     *generationDir,
	}

	generator, err := NewStoryVideoGenerator(config)
	if err != nil {
		fmt.Printf("✗ Failed to create generator: %v\n", err)
		os.Exit(1)
	}

	startTime := time.Now()

	var timeline []Scene
	if *storyFile != "" {
		timeline, err = generator.LoadStoryFromFile(*storyFile)
		if err != nil {
			fmt.Printf("✗ Failed to load story file: %v\n", err)
			os.Exit(1)
		}
	} else {
		timeline = generator.CreateStoryTimeline(*prompt, *duration, *segmentDuration)
	}

	finalVideo, err := generator.GenerateStoryVideo(
		timeline,
		*seed,
		*outputName,
		!*noTemporalConsistency,
	)
	if err != nil {
		fmt.Printf("✗ Failed to generate story video: %v\n", err)
		os.Exit(1)
	}

	if err := generator.Cleanup(*keepSegments); err != nil {
		fmt.Printf("Warning: Cleanup failed: %v\n", err)
	}

	elapsed := time.Since(startTime)
	totalDur := 0
	for _, s := range timeline {
		totalDur += s.Duration
	}

	fmt.Println(strings.Repeat("=", 60))
	fmt.Println("✓ SUCCESS!")
	fmt.Printf("  Video: %s\n", finalVideo)
	fmt.Printf("  Duration: %ds (%.1f min)\n", totalDur, float64(totalDur)/60)
	fmt.Printf("  Time taken: %.1fs (%.1f min)\n", elapsed.Seconds(), elapsed.Minutes())
	fmt.Printf("  Scenes: %d\n", len(timeline))
	fmt.Println(strings.Repeat("=", 60))
}
