# simprel GUI story builder

#!/usr/bin/env python3
"""
Simple GUI Story Builder for Long Video Generation
Helps create JSON timelines without manual typing
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, filedialog
import json
from pathlib import Path

class StoryBuilderGUI:
def **init**(self, root):
self.root = root
self.root.title("Long Video Story Builder")
self.root.geometry("1000x700")

        # Scenes storage
        self.scenes = []

        self.create_widgets()

    def create_widgets(self):
        # Main container
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Environment section
        env_frame = ttk.LabelFrame(main_frame, text="Base Environment (Applied to ALL scenes)", padding="10")
        env_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)

        ttk.Label(env_frame, text="Describe the location, colors, lighting, style:").grid(row=0, column=0, sticky=tk.W)
        self.env_text = scrolledtext.ScrolledText(env_frame, height=3, width=100, wrap=tk.WORD)
        self.env_text.grid(row=1, column=0, pady=5)
        self.env_text.insert(1.0, "Modern living room with sage green walls, cream leather sofa, oak coffee table, large window with sheer curtains, warm afternoon sunlight")

        # Scene input section
        scene_frame = ttk.LabelFrame(main_frame, text="Add Scene", padding="10")
        scene_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)

        ttk.Label(scene_frame, text="Action/What Happens:").grid(row=0, column=0, sticky=tk.W)
        self.action_text = scrolledtext.ScrolledText(scene_frame, height=2, width=80, wrap=tk.WORD)
        self.action_text.grid(row=1, column=0, columnspan=2, pady=5)

        ttk.Label(scene_frame, text="Duration (seconds):").grid(row=2, column=0, sticky=tk.W)
        self.duration_var = tk.StringVar(value="5")
        duration_entry = ttk.Entry(scene_frame, textvariable=self.duration_var, width=10)
        duration_entry.grid(row=2, column=1, sticky=tk.W, pady=5)

        btn_frame = ttk.Frame(scene_frame)
        btn_frame.grid(row=3, column=0, columnspan=2, pady=5)

        ttk.Button(btn_frame, text="Add Scene", command=self.add_scene).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="Clear", command=self.clear_scene_input).pack(side=tk.LEFT, padx=5)

        # Scenes list section
        list_frame = ttk.LabelFrame(main_frame, text="Story Timeline", padding="10")
        list_frame.grid(row=2, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=5, padx=(0, 5))

        # Treeview for scenes
        columns = ("num", "duration", "action")
        self.tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        self.tree.heading("num", text="#")
        self.tree.heading("duration", text="Duration")
        self.tree.heading("action", text="Action")
        self.tree.column("num", width=40)
        self.tree.column("duration", width=80)
        self.tree.column("action", width=400)

        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscroll=scrollbar.set)

        self.tree.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        scrollbar.grid(row=0, column=1, sticky=(tk.N, tk.S))

        # Scene management buttons
        mgmt_frame = ttk.Frame(list_frame)
        mgmt_frame.grid(row=1, column=0, columnspan=2, pady=5)

        ttk.Button(mgmt_frame, text="Move Up", command=self.move_up).pack(side=tk.LEFT, padx=2)
        ttk.Button(mgmt_frame, text="Move Down", command=self.move_down).pack(side=tk.LEFT, padx=2)
        ttk.Button(mgmt_frame, text="Delete", command=self.delete_scene).pack(side=tk.LEFT, padx=2)
        ttk.Button(mgmt_frame, text="Clear All", command=self.clear_all).pack(side=tk.LEFT, padx=2)

        # Preview section
        preview_frame = ttk.LabelFrame(main_frame, text="Full Prompt Preview", padding="10")
        preview_frame.grid(row=2, column=1, sticky=(tk.W, tk.E, tk.N, tk.S), pady=5)

        self.preview_text = scrolledtext.ScrolledText(preview_frame, height=15, width=50, wrap=tk.WORD)
        self.preview_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Stats section
        stats_frame = ttk.Frame(main_frame)
        stats_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)

        self.stats_label = ttk.Label(stats_frame, text="Scenes: 0 | Total Duration: 0s (0.0 min)")
        self.stats_label.pack(side=tk.LEFT)

        # Action buttons
        action_frame = ttk.Frame(main_frame)
        action_frame.grid(row=4, column=0, columnspan=2, pady=10)

        ttk.Button(action_frame, text="Load JSON", command=self.load_json).pack(side=tk.LEFT, padx=5)
        ttk.Button(action_frame, text="Save JSON", command=self.save_json).pack(side=tk.LEFT, padx=5)
        ttk.Button(action_frame, text="Generate Video", command=self.generate_video).pack(side=tk.LEFT, padx=5)

        # Templates menu
        ttk.Button(action_frame, text="Load Template", command=self.show_templates).pack(side=tk.LEFT, padx=5)

        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(2, weight=1)

        # Bind selection event
        self.tree.bind('<<TreeviewSelect>>', self.on_scene_select)

    def add_scene(self):
        action = self.action_text.get(1.0, tk.END).strip()
        if not action:
            messagebox.showwarning("Warning", "Please enter an action description")
            return

        try:
            duration = int(self.duration_var.get())
            if duration <= 0:
                raise ValueError()
        except ValueError:
            messagebox.showerror("Error", "Duration must be a positive number")
            return

        scene = {
            "action": action,
            "duration": duration
        }

        self.scenes.append(scene)
        self.update_tree()
        self.clear_scene_input()
        self.update_stats()

    def clear_scene_input(self):
        self.action_text.delete(1.0, tk.END)
        self.duration_var.set("5")

    def update_tree(self):
        # Clear tree
        for item in self.tree.get_children():
            self.tree.delete(item)

        # Repopulate
        for i, scene in enumerate(self.scenes, 1):
            action_preview = scene['action'][:50] + "..." if len(scene['action']) > 50 else scene['action']
            self.tree.insert("", tk.END, values=(i, f"{scene['duration']}s", action_preview))

    def on_scene_select(self, event):
        selection = self.tree.selection()
        if not selection:
            return

        item = selection[0]
        idx = self.tree.index(item)

        if idx < len(self.scenes):
            scene = self.scenes[idx]
            base_env = self.env_text.get(1.0, tk.END).strip()
            full_prompt = f"{base_env} - {scene['action']}"

            self.preview_text.delete(1.0, tk.END)
            self.preview_text.insert(1.0, f"Scene {idx + 1}:\n\n{full_prompt}\n\nDuration: {scene['duration']}s")

    def move_up(self):
        selection = self.tree.selection()
        if not selection:
            return

        idx = self.tree.index(selection[0])
        if idx > 0:
            self.scenes[idx], self.scenes[idx-1] = self.scenes[idx-1], self.scenes[idx]
            self.update_tree()
            self.update_stats()

    def move_down(self):
        selection = self.tree.selection()
        if not selection:
            return

        idx = self.tree.index(selection[0])
        if idx < len(self.scenes) - 1:
            self.scenes[idx], self.scenes[idx+1] = self.scenes[idx+1], self.scenes[idx]
            self.update_tree()
            self.update_stats()

    def delete_scene(self):
        selection = self.tree.selection()
        if not selection:
            return

        idx = self.tree.index(selection[0])
        del self.scenes[idx]
        self.update_tree()
        self.update_stats()

    def clear_all(self):
        if messagebox.askyesno("Confirm", "Clear all scenes?"):
            self.scenes = []
            self.update_tree()
            self.update_stats()

    def update_stats(self):
        total_duration = sum(s['duration'] for s in self.scenes)
        minutes = total_duration / 60
        self.stats_label.config(
            text=f"Scenes: {len(self.scenes)} | Total Duration: {total_duration}s ({minutes:.1f} min)"
        )

    def save_json(self):
        if not self.scenes:
            messagebox.showwarning("Warning", "No scenes to save")
            return

        filename = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
        )

        if filename:
            base_env = self.env_text.get(1.0, tk.END).strip()
            timeline = []

            for scene in self.scenes:
                full_prompt = f"{base_env} - {scene['action']}"
                timeline.append({
                    "prompt": full_prompt,
                    "duration": scene['duration']
                })

            with open(filename, 'w') as f:
                json.dump(timeline, f, indent=2)

            messagebox.showinfo("Success", f"Saved {len(timeline)} scenes to {filename}")

    def load_json(self):
        filename = filedialog.askopenfilename(
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
        )

        if filename:
            try:
                with open(filename, 'r') as f:
                    timeline = json.load(f)

                # Try to extract base environment from first prompt
                if timeline and 'prompt' in timeline[0]:
                    first_prompt = timeline[0]['prompt']
                    if ' - ' in first_prompt:
                        base_env, _ = first_prompt.split(' - ', 1)
                        self.env_text.delete(1.0, tk.END)
                        self.env_text.insert(1.0, base_env)

                # Load scenes
                self.scenes = []
                for scene in timeline:
                    prompt = scene['prompt']
                    if ' - ' in prompt:
                        _, action = prompt.split(' - ', 1)
                    else:
                        action = prompt

                    self.scenes.append({
                        "action": action,
                        "duration": scene.get('duration', 5)
                    })

                self.update_tree()
                self.update_stats()
                messagebox.showinfo("Success", f"Loaded {len(self.scenes)} scenes")

            except Exception as e:
                messagebox.showerror("Error", f"Failed to load file: {e}")

    def show_templates(self):
        template_window = tk.Toplevel(self.root)
        template_window.title("Story Templates")
        template_window.geometry("600x400")

        ttk.Label(template_window, text="Choose a template:", padding=10).pack()

        templates = {
            "Boxing Match": self.load_boxing_template,
            "Office Meeting": self.load_office_template,
            "Nature Documentary": self.load_nature_template,
            "Cooking Show": self.load_cooking_template,
        }

        for name, func in templates.items():
            ttk.Button(
                template_window,
                text=name,
                command=lambda f=func: [f(), template_window.destroy()]
            ).pack(pady=5)

    def load_boxing_template(self):
        self.env_text.delete(1.0, tk.END)
        self.env_text.insert(1.0, "Professional boxing ring with spotlights, crowd in background, dramatic lighting")

        self.scenes = [
            {"action": "empty ring, establishing shot", "duration": 5},
            {"action": "two anthropomorphic cats in boxing gear entering from opposite corners", "duration": 5},
            {"action": "cats touching gloves at center, referee between them", "duration": 5},
            {"action": "bell rings, cats start circling each other", "duration": 5},
            {"action": "first cat throws jab, second cat blocks", "duration": 5},
            {"action": "intense exchange of punches", "duration": 8},
            {"action": "first cat lands powerful hook", "duration": 5},
            {"action": "second cat staggers back", "duration": 5},
            {"action": "final knockout punch in slow motion", "duration": 10},
            {"action": "winner celebrating, crowd cheering", "duration": 8},
        ]

        self.update_tree()
        self.update_stats()

    def load_office_template(self):
        self.env_text.delete(1.0, tk.END)
        self.env_text.insert(1.0, "Modern office with white walls, glass desk, city view through windows, bright daylight")

        self.scenes = [
            {"action": "empty office, establishing shot", "duration": 5},
            {"action": "businesswoman enters with briefcase", "duration": 5},
            {"action": "sits at desk, opens laptop", "duration": 5},
            {"action": "typing focused on work", "duration": 8},
            {"action": "knock on door, colleague enters", "duration": 5},
            {"action": "colleague hands documents", "duration": 5},
            {"action": "both reviewing documents together", "duration": 8},
            {"action": "shaking hands, agreement reached", "duration": 5},
        ]

        self.update_tree()
        self.update_stats()

    def load_nature_template(self):
        self.env_text.delete(1.0, tk.END)
        self.env_text.insert(1.0, "African savanna at golden hour, vast grasslands, acacia trees, warm sunset light")

        self.scenes = [
            {"action": "wide landscape shot, sun setting", "duration": 8},
            {"action": "lion pride resting under tree", "duration": 8},
            {"action": "cubs playing together", "duration": 8},
            {"action": "lioness standing alert", "duration": 5},
            {"action": "herd of gazelles in distance", "duration": 8},
            {"action": "lion starts stalking", "duration": 8},
        ]

        self.update_tree()
        self.update_stats()

    def load_cooking_template(self):
        self.env_text.delete(1.0, tk.END)
        self.env_text.insert(1.0, "Professional kitchen with stainless steel appliances, marble countertop, bright overhead lighting")

        self.scenes = [
            {"action": "chef arranging ingredients on counter", "duration": 5},
            {"action": "chef chopping vegetables skillfully", "duration": 8},
            {"action": "heating pan on stove", "duration": 5},
            {"action": "adding ingredients to pan with dramatic sizzle", "duration": 8},
            {"action": "stirring and seasoning", "duration": 5},
            {"action": "plating the finished dish beautifully", "duration": 8},
        ]

        self.update_tree()
        self.update_stats()

    def generate_video(self):
        if not self.scenes:
            messagebox.showwarning("Warning", "No scenes to generate")
            return

        # Save JSON first
        temp_json = "temp_story.json"
        base_env = self.env_text.get(1.0, tk.END).strip()
        timeline = []

        for scene in self.scenes:
            full_prompt = f"{base_env} - {scene['action']}"
            timeline.append({
                "prompt": full_prompt,
                "duration": scene['duration']
            })

        with open(temp_json, 'w') as f:
            json.dump(timeline, f, indent=2)

        # Show command
        cmd = f"""python story_video_generator.py \\

--story_file {temp_json} \\
--ckpt_dir ./Wan2.1-T2V-1.3B \\
--model t2v-1.3B \\
--output_name generated_story.mp4"""

        result_window = tk.Toplevel(self.root)
        result_window.title("Generation Command")
        result_window.geometry("700x300")

        ttk.Label(result_window, text="Story saved! Run this command:", padding=10).pack()

        cmd_text = scrolledtext.ScrolledText(result_window, height=10, width=80)
        cmd_text.pack(padx=10, pady=10)
        cmd_text.insert(1.0, cmd)

        ttk.Button(
            result_window,
            text="Copy to Clipboard",
            command=lambda: [self.root.clipboard_clear(), self.root.clipboard_append(cmd)]
        ).pack(pady=5)

def main():
root = tk.Tk()
app = StoryBuilderGUI(root)
root.mainloop()

if **name** == "**main**":
main()

````

## How to Use the GUI:

```bash
# Install tkinter if needed (usually pre-installed)
# Ubuntu: sudo apt-get install python3-tk

# Run the GUI
python story_builder.py
````

### Features:

✅ Visual scene builder  
✅ Base environment auto-applied  
✅ Drag to reorder scenes  
✅ Load/save JSON  
✅ Templates (boxing, office, nature, cooking)  
✅ Live preview of full prompts  
✅ Duration calculator  
✅ One-click export to JSON

---

## Final Recommendation:

**Use the GUI to BUILD, then JSON to GENERATE**

1. **Use `story_builder.py`** - Easy visual creation
2. **Export to JSON** - Your story file
3. **Use `story_video_generator.py`** - Generate video
4. **Edit JSON manually** - For fine-tuning

This gives you the best of both worlds! 🎬
