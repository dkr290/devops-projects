#!/bin/bash

sudo apt update && sudo apt -y install podman
sudo podman run --name web1 -d -p 80:8080 ghcr.io/dkr290/devops-projects/goappv2:c0322977
