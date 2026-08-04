#!/bin/bash
set -e

# --- Wan2GP Live Update Script ---
# This script updates the Wan2GP application in a running RunPod container.
# It is designed to work around the environment's auto-restart mechanism.
# Note: Changes are temporary. A full pod restart will revert to the
# version specified in the Dockerfile.


echo "--- Starting Wan2GP Live Update ---"


cd /workspace/Wan2GP
echo "Stashing local changes to avoid conflicts..."
git stash

git switch main
git pull origin main
echo "Successfully pulled latest code from the 'main' branch."


echo ""
echo "✅ --- Update Complete ---"
echo "Now stop and start the container to pick up the new code:"
echo "  docker stop wan2gp && docker start wan2gp"


