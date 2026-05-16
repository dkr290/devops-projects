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

```
docker run --gpus all \
   -d --name wan2gp \
   -p 7860:7860 \
   -v ~/wan2gp-data/workspace:/workspace \
   -v ~/wan2gp-data/huggingface:/root/.cache/huggingface \
   -v ~/wan2gp-data/torch:/root/.cache/torch \
   -e HF_HOME=/root/.cache/huggingface \
   ghcr.io/dkr290/devops-projects/wan2gp:wan2gp-v11.66


```

