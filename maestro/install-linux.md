1.  Clone the repository:


```
git clone https://github.com/Blizaine/Maestro.git
cd Maestro
```

2. Create and activate the virtual environment inside Maestro/venv:

```
uv venv venv --python 3.10
source venv/bin/activate
```

3. Install Python dependencies:
Note: Standard uv pip install -r app/requirements.txt fails due to uv's default strict index matching on onnxruntime-gpu==1.22.0 (which exists on PyPI rather than the custom Azure nightly index). Use --index-strategy unsafe-best-match to resolve across all indexes.

```
uv pip install --index-strategy unsafe-best-match -r app/requirements.txt
```

4. Maestro's React frontend (ui/dist) is not pre-built. If omitted, the server falls back to serving only the REST API and the Gradio classic UI at /classic.
Issue Encountered

Running npm run build with default Ubuntu/Debian apt packages (Node.js v18.19.1) triggers a safety check failure:

```
sudo apt remove -y nodejs npm
sudo apt purge -y nodejs
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

5. Install dependencies and build the React UI
```
cd ~/Maestro/ui
npm install
npm run build
cd ~/Maestro
```


6. Running Maestro on 0.0.0.0

app/launch.py ignores CLI flags like --host and reads configuration from environment variables (SERVER_NAME and SERVER_PORT).

```
cd ~/Maestro
source venv/bin/activate
SERVER_NAME=0.0.0.0 SERVER_PORT=7860 python app/launch.py

```
7. Updating Maestro Later

Because the virtual environment is isolated inside Maestro/venv (ignored by Git), future updates require only pulling the repository and syncing dependencies:

```
cd ~/Maestro
git pull
source venv/bin/activate
uv pip install --index-strategy unsafe-best-match -r app/requirements.txt
cd ui && npm install && npm run build && cd ..
```


## On windows 

Step 1: Set Up Portable Node.js (ARM64)Node.js provides official standalone .zip archives specifically compiled for Windows ARM64.Download the Windows ARM64 binary archive:Go to the official Node.js downloads archive ([https://nodejs.org/en/download/archive/current](https://nodejs.org/en/download/archive/current)) and download the Windows ARM64 .zip file (e.g., node-v24.x.x-win-arm64.zip or node-v26.x.x-win-arm64.zip — any version $\ge$ v20 works).Extract into your Maestro folder:Clone Maestro first (git clone [https://github.com/Blizaine/Maestro.git](https://github.com/Blizaine/Maestro.git)).Extract the .zip archive directly into a subfolder inside Maestro and rename the extracted folder to node so the binary path is Maestro\node\node.exe.Verify portable Node.js:Open PowerShell inside your Maestro folder and run:

```
.\node\node.exe -v

```
Step 2: Set Up Portable uv & Python (ARM64)

To keep the Python backend just as portable as Node.js:

    Download uv for Windows ARM64:

        Grab uv-aarch64-pc-windows-msvc.zip from Astral's uv GitHub Releases page and extract uv.exe into Maestro\uv\uv.exe.

Step 3: Create a local virtual environment inside Maestro\venv:

```
.\uv\uv.exe venv venv --python 3.10
```

(Note: If you encounter missing ARM64 wheels for AI packages like PyTorch or onnxruntime-gpu, uv can also pull x64 Windows Python builds via --python cpython-3.10-windows-x86_64-none, which Windows 11 on ARM runs seamlessly via Prism emulation).

3. Install backend dependencies:
```
.\venv\Scripts\python.exe -m pip install --upgrade pip
.\uv\uv.exe pip install --python .\venv\Scripts\python.exe --index-strategy unsafe-best-match -r app\requirements.txt
```

4. Step 3: Build the React UI Portably

Temporarily prepend your local node folder to the session PATH so npm uses your portable runtime to compile ui\dist:

```

$env:PATH = "$PWD\node;$env:PATH"
cd ui
npm install
npm run build
cd ..
```


5. Step 4: Create a Self-Contained Launcher bat file 

```
@echo off
setlocal

:: Use local portable Node and uv binaries
set "PATH=%~dp0node;%~dp0uv;%PATH%"

:: Bind to all network interfaces on port 7860
set "SERVER_NAME=0.0.0.0"  
set "SERVER_PORT=7860"

:: Launch Maestro using the local virtual environment
"%~dp0venv\Scripts\python.exe" "%~dp0app\launch.py"

pause

```
