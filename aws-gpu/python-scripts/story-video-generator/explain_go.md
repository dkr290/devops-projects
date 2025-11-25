## 2. Data Structures

### Scene Struct

```go
type Scene struct {
	Prompt     string  `json:"prompt"`       // Text description of scene
	Duration   int     `json:"duration"`     // How long in seconds
	SeedOffset int     `json:"seed_offset"`  // Random seed variation
}
```

- `struct` = Go's equivalent of a Python class (data only, no methods attached)
- JSON tags (`` `json:"prompt"` ``) tell Go how to map JSON fields to struct fields
- Example JSON:

```json
{
  "prompt": "Two cats boxing",
  "duration": 5,
  "seed_offset": 100
}
```

### StoryVideoGenerator Struct

```go
type StoryVideoGenerator struct {
	ModelType          string   // e.g., "t2v-1.3B"
	CkptDir            string   // "./Wan2.1-T2V-1.3B"
	Size               string   // "832*480"
	FPS                int      // 24
	OutputDir          string   // Where to save final video
	SampleShift        float64  // Model parameter
	SampleGuideScale   float64  // Model parameter
	OffloadModel       bool     // Memory optimization flag
	ConvertModelDtype  bool     // Data type conversion flag
	GenerationDir      string   // Where generate.py saves files
	SegmentsDir        string   // Where we save individual segments
}
```

- Holds all configuration for video generation
- In Python this was `self.model_type`, etc.
- In Go, these are fields of a struct

### GeneratorConfig Struct

```go
type GeneratorConfig struct {
	ModelType         string
	CkptDir           string
	// ... same fields as StoryVideoGenerator
}
```

- Used to pass configuration to constructor
- Go doesn't have default parameters, so we use a config struct pattern

## 3. Constructor Function

```go
func NewStoryVideoGenerator(config GeneratorConfig) (*StoryVideoGenerator, error) {
	g := &StoryVideoGenerator{
		ModelType:         config.ModelType,
		CkptDir:           config.CkptDir,
		// ... copy all fields
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
```

**How it works:**

1. Creates new `StoryVideoGenerator` instance
2. `&` creates a pointer (like Python object reference)
3. `filepath.Join` = path concatenation (like `os.path.join`)
4. `os.MkdirAll` = creates directory with all parents (like `mkdir -p`)
5. `0755` = Unix permissions (rwxr-xr-x)
6. Returns `(pointer, error)` - Go's error handling pattern
7. `fmt.Errorf` with `%w` wraps errors for context

**Python equivalent:**

```python
def __init__(self, model_type, ckpt_dir, ...):
    self.model_type = model_type
    self.output_dir.mkdir(exist_ok=True, parents=True)
```

## 4. CreateStoryTimeline - Auto-Generate Story

```go
func (g *StoryVideoGenerator) CreateStoryTimeline(mainPrompt string, duration, segmentDuration int) []Scene {
	totalScenes := (duration + segmentDuration - 1) / segmentDuration  // Ceiling division
	timeline := make([]Scene, 0, totalScenes)  // Empty slice with capacity
```

**Method receiver:** `(g *StoryVideoGenerator)`

- This is how Go attaches methods to structs
- `g` is like `self` in Python
- `*` means pointer receiver (can modify the struct)

**Slice creation:** `make([]Scene, 0, totalScenes)`

- `[]Scene` = slice of Scene structs (like Python list)
- `0` = initial length (empty)
- `totalScenes` = capacity (pre-allocated memory)

```go
	promptLower := strings.ToLower(mainPrompt)
	if strings.Contains(promptLower, "boxing") || strings.Contains(promptLower, "fight") {
```

- Special logic for boxing/fight videos
- Creates cinematic phases

```go
		phases := []struct {
			desc      string
			numScenes int
		}{
			{"entering the ring, dramatic lighting, crowd cheering", 6},
			{"circling each other, testing jabs, defensive stance", 12},
			// ... more phases
		}
```

- Anonymous struct slice (inline data structure)
- Each phase has description and number of scenes

```go
		for _, phase := range phases {
			numToAdd := min(phase.numScenes, totalScenes-len(timeline))
			for i := 0; i < numToAdd; i++ {
				timeline = append(timeline, Scene{
					Prompt:     fmt.Sprintf("%s %s", baseSubject, phase.desc),
					Duration:   segmentDuration,
					SeedOffset: len(timeline) * 100,
				})
			}
```

- `range` iterates over slice (like Python `for item in list`)
- `_` discards index (we don't need it)
- `append` adds to slice (like Python `list.append()`)
- `fmt.Sprintf` = formatted string (like Python f-strings)

## 5. LoadStoryFromFile - Parse JSON

```go
func (g *StoryVideoGenerator) LoadStoryFromFile(storyFile string) ([]Scene, error) {
	data, err := os.ReadFile(storyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read story file: %w", err)
	}
```

- **Error handling pattern in Go:**
  - Functions return `(result, error)`
  - Always check `if err != nil`
  - Return early if error
  - No exceptions/try-catch

```go
	var timeline []Scene
	if err := json.Unmarshal(data, &timeline); err != nil {
		return nil, fmt.Errorf("failed to parse story file: %w", err)
	}
```

- `var timeline []Scene` declares empty slice
- `json.Unmarshal` parses JSON into Go struct
- `&timeline` passes pointer so function can modify it

```go
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
```

- `range` with single variable gives index only
- `nil` error means success

## 6. FindLatestVideo - Locate Generated File

```go
func (g *StoryVideoGenerator) FindLatestVideo(beforeTime time.Time) (string, error) {
	patterns := []string{
		"*.mp4",
		"output*.mp4",
		// ... more patterns
	}

	var latestFile string
	latestTime := beforeTime

	for _, pattern := range patterns {
		matches, _ := filepath.Glob(filepath.Join(g.GenerationDir, pattern))
```

- `filepath.Glob` finds files matching wildcard pattern
- `_` discards error (we don't care if pattern matches nothing)

```go
		for _, match := range matches {
			info, err := os.Stat(match)
			if err != nil {
				continue  // Skip files we can't stat
			}
			if info.ModTime().After(latestTime) {
				latestTime = info.ModTime()
				latestFile = match
			}
		}
	}
```

- `os.Stat` gets file info (size, modification time, etc.)
- `info.ModTime()` returns modification time
- `.After()` compares times

## 7. GenerateSegment - Core Video Generation

```go
func (g *StoryVideoGenerator) GenerateSegment(prompt string, segmentIdx, seed int, imagePath string) (string, error) {
	outputFile := filepath.Join(g.SegmentsDir, fmt.Sprintf("segment_%04d.mp4", segmentIdx))
```

- `%04d` = zero-padded 4-digit number (0001, 0002, etc.)

```go
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
```

- Building command-line arguments
- `%.1f` = float with 1 decimal place
- `%d` = integer

```go
	if g.OffloadModel {
		args = append(args, "--offload_model", "True")
	}
```

- Conditionally add arguments

```go
	cmd := exec.Command("python", args...)
	output, err := cmd.CombinedOutput()
```

- `exec.Command` creates command object
- `args...` spreads slice into variadic arguments
- `CombinedOutput()` runs command and captures stdout+stderr

```go
	if err != nil {
		return "", fmt.Errorf("generation failed: %w\nOutput: %s", err, string(output))
	}
	fmt.Print(string(output))
```

- Print command output
- `string(output)` converts `[]byte` to string

```go
	// Find generated video
	generatedFile, err := g.FindLatestVideo(beforeTime)
	if err == nil && generatedFile != "" {
		if err := os.Rename(generatedFile, outputFile); err != nil {
			return "", fmt.Errorf("failed to move generated file: %w", err)
		}
```

- Find newly created video file
- `os.Rename` = move/rename file

```go
	// Try common default locations
	possiblePaths := []string{
		"output.mp4",
		"generated.mp4",
		fmt.Sprintf("sample_%d.mp4", seed),
	}

	for _, path := range possiblePaths {
		if _, err := os.Stat(path); err == nil {  // File exists
			if err := os.Rename(path, outputFile); err != nil {
				return "", err
			}
			return outputFile, nil
		}
	}
```

- Fallback: check common filenames
- `os.Stat` returns error if file doesn't exist

## 8. ExtractLastFrame - FFmpeg Frame Extraction

```go
func (g *StoryVideoGenerator) ExtractLastFrame(videoPath, outputPath string) error {
	cmd := exec.Command("ffmpeg",
		"-y",              // Overwrite
		"-sseof", "-1",    // Seek to 1 second before end
		"-i", videoPath,   // Input file
		"-update", "1",    // Update single image
		"-q:v", "1",       // Best quality
		outputPath,        // Output file
	)
	return cmd.Run()
}
```

- Creates FFmpeg command
- `cmd.Run()` executes and waits for completion
- Returns error if FFmpeg fails

## 9. StitchVideos - Concatenate Segments

```go
func (g *StoryVideoGenerator) StitchVideos(segmentFiles []string, outputPath string) error {
	concatFile := filepath.Join(g.OutputDir, "concat_list.txt")

	// Create concat file
	var content strings.Builder
	for _, seg := range segmentFiles {
		absPath, _ := filepath.Abs(seg)
		content.WriteString(fmt.Sprintf("file '%s'\n", absPath))
	}
```

- `strings.Builder` efficiently builds strings (like Python `StringIO`)
- `.WriteString()` appends to builder
- Creates FFmpeg concat list file

```go
	if err := os.WriteFile(concatFile, []byte(content.String()), 0644); err != nil {
		return fmt.Errorf("failed to create concat file: %w", err)
	}
```

- Write concat list to file
- `[]byte(...)` converts string to byte slice
- `0644` = rw-r--r-- permissions

```go
	cmd := exec.Command("ffmpeg",
		"-y",
		"-f", "concat",
		"-safe", "0",
		"-i", concatFile,
		"-c", "copy",      // Copy codec (no re-encode)
		outputPath,
	)

	if err := cmd.Run(); err != nil {
		// Fallback: re-encode
		cmd = exec.Command("ffmpeg",
			"-y",
			"-f", "concat",
			"-safe", "0",
			"-i", concatFile,
			"-c:v", "libx264",  // Re-encode with H.264
			"-preset", "fast",
			"-crf", "18",        // Quality setting
			outputPath,
		)
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("stitching failed: %w", err)
		}
	}
```

- Try fast copy method first
- If fails, re-encode (slower but more compatible)

## 10. GenerateStoryVideo - Main Orchestration

```go
func (g *StoryVideoGenerator) GenerateStoryVideo(timeline []Scene, baseSeed int, outputName string, useTemporalConsistency bool) (string, error) {
	totalDuration := 0
	for _, scene := range timeline {
		totalDuration += scene.Duration
	}
```

- Calculate total video duration

```go
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
```

- Temporal consistency: use last frame of previous segment as input
- Only works with certain model types (TI2V, VACE)

```go
		segmentFile, err := g.GenerateSegment(scene.Prompt, i, seed, imageInput)
		if err != nil {
			fmt.Printf("✗ Failed to generate scene %d: %v\n", i+1, err)
			fmt.Println("Continuing with remaining scenes...")
			continue  // Skip failed scene, keep going
		}

		segmentFiles = append(segmentFiles, segmentFile)
```

- Generate each segment
- Continue on error instead of failing completely

```go
		if useTemporalConsistency && i < len(timeline)-1 {
			lastFramePath = filepath.Join(g.SegmentsDir, fmt.Sprintf("last_frame_%04d.png", i))
			_ = g.ExtractLastFrame(segmentFile, lastFramePath)
		}
	}
```

- Extract last frame for next segment
- `_` discards error (non-critical operation)

## 11. Cleanup Function

```go
func (g *StoryVideoGenerator) Cleanup(keepSegments bool) error {
	if keepSegments {
		return nil
	}

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
```

- Delete temporary segment files
- `os.ReadDir` lists directory contents
- `os.Remove` deletes file

## 12. Helper Functions

```go
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
```

- Go doesn't have built-in min/max for integers
- Must define ourselves

## 13. Main Function - Program Entry Point

```go
func main() {
	// Command line flags
	prompt := flag.String("prompt", "", "Main prompt...")
	storyFile := flag.String("story_file", "", "JSON file...")
	ckptDir := flag.String("ckpt_dir", "", "Model checkpoint...")
	// ... more flags
```

- `flag.String()` defines string flag
- Returns pointer to string value
- First arg = flag name, second = default, third = description

```go
	flag.Parse()
```

- Parses command-line arguments
- Must call before accessing flag values

```go
	if *prompt == "" && *storyFile == "" {
		fmt.Println("Error: Must provide either --prompt or --story_file")
		flag.Usage()
		os.Exit(1)
	}
```

- Validation
- `*prompt` dereferences pointer to get value
- `flag.Usage()` prints help message
- `os.Exit(1)` exits with error code

```go
	config := GeneratorConfig{
		ModelType:         *model,
		CkptDir:           *ckptDir,
		// ... all fields
	}

	generator, err := NewStoryVideoGenerator(config)
	if err != nil {
		fmt.Printf("✗ Failed to create generator: %v\n", err)
		os.Exit(1)
	}
```

- Create config struct
- Call constructor
- Handle error

```go
	startTime := time.Now()

	var timeline []Scene
	if *storyFile != "" {
		timeline, err = generator.LoadStoryFromFile(*storyFile)
	} else {
		timeline = generator.CreateStoryTimeline(*prompt, *duration, *segmentDuration)
	}
```

- Record start time
- Load or create timeline

```go
	finalVideo, err := generator.GenerateStoryVideo(
		timeline,
		*seed,
		*outputName,
		!*noTemporalConsistency,
	)
```

- Generate video
- `!*noTemporalConsistency` = invert boolean flag

```go
	elapsed := time.Since(startTime)

	fmt.Printf("  Time taken: %.1fs (%.1f min)\n", elapsed.Seconds(), elapsed.Minutes())
```

- `time.Since()` calculates duration
- `.Seconds()` and `.Minutes()` convert to different units

## Key Go Concepts Used

### 1. **Error Handling**

```go
result, err := someFunction()
if err != nil {
    return nil, fmt.Errorf("context: %w", err)
}
```

- No exceptions
- Explicit error checking
- `%w` wraps errors for stack trace

### 2. **Pointers**

```go
func (g *StoryVideoGenerator) Method() { }  // Pointer receiver
config := &GeneratorConfig{}                 // Address-of operator
value := *pointer                            // Dereference
```

### 3. **Slices** (dynamic arrays)

```go
timeline := make([]Scene, 0, 10)  // length 0, capacity 10
timeline = append(timeline, scene) // Add element
```

### 4. **Structs** (data structures)

```go
type Scene struct {
    Prompt string
    Duration int
}
```

### 5. **Methods** (functions on structs)

```go
func (g *Generator) Method(arg string) error { }
```

### 6. **Command Execution**

```go
cmd := exec.Command("python", "script.py", "--arg", "value")
output, err := cmd.CombinedOutput()
```

This Go version is fully equivalent to the Python version but with Go's patterns for error handling, memory management, and concurrency-safety!

## Me

> Context:
>
> - 󰂥 <buf>aws-gpu/python-scripts/story_video_generator.py</buf>
