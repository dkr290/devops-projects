# Prerequisites

- install cuda
- Install the container toolkit in order docker to work

```
sudo apt-get -y install cuda-toolkit-13-1
sudo apt install -y nvidia-container-toolkit

```

- if not done install latest cuda drivers

```

sudo  ubuntu-drivers install
```

# Installation

- To start the container:

```
mkdir -p ~/wan2gp-data/{workspace,huggingface,torch}

docker run --gpus all -it --rm \
  -p 7860:7860 \
  -v ~/wan2gp-data/workspace:/workspace \
  -v ~/wan2gp-data/huggingface:/root/.cache/huggingface \
  -v ~/wan2gp-data/torch:/root/.cache/torch \
  -e HF_HOME=/root/.cache/huggingface \
  wan2gp-local
```

- Or simply in background mode

```bash
docker run --gpus all \
   -d --name wan2gp \
   -p 7860:7860 \
   -v ~/wan2gp-data/workspace:/workspace \
   -v ~/wan2gp-data/huggingface:/root/.cache/huggingface \
   -v ~/wan2gp-data/torch:/root/.cache/torch \
   -e HF_HOME=/root/.cache/huggingface \
   ghcr.io/dkr290/devops-projects/wan2gp:wan2gp-v11.66


```

# Undervold the RTX card

- create the following script and make it executable

```

cat /usr/local/bin/3090-powerlimit.sh
#!/bin/bash
nvidia-smi -pl 300

```

- Create systemd service

```
cat /etc/systemd/system/3090-powerlimit.service
[Unit]
Description=Permanent RTX 3090 Power Limit
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/3090-powerlimit.sh

[Install]
WantedBy=multi-user.target

```

## good to have nvitop and a tool for monitoring GPU temp

- check if secure boot is disabled

```
mokutil --sb-state
```

- add kernel parameter

```
sudo nano /etc/default/grub
# repolace
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

#with
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash iomem=relaxed"
sudo update-grub
sudo reboot
sudo apt update
sudo apt install git build-essential
sudo apt install libpci-dev -y
git clone https://github.com/olealgoritme/gddr6
cd gddr6
./build_install.sh
sudo gddr6
```
