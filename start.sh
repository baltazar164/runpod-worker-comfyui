#!/usr/bin/env bash

echo "Worker Initiated"

# ============================================================================
# WORKER STARTUP IDENTIFICATION
# ============================================================================
echo ""
echo "🔍 DEBUG: RunPod Worker Startup"
echo "============================================================================"
echo ""
echo "📌 Build Identification:"
echo "   Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "   Git Commit: $(cd /workspace && git rev-parse HEAD 2>/dev/null || echo 'ERROR: Not a git repo')"
echo "   Git Branch: $(cd /workspace && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
echo "   Git Remote: $(cd /workspace && git config --get remote.origin.url 2>/dev/null || echo 'N/A')"
echo ""
echo "🔧 Environment:"
echo "   Python: $(python --version 2>&1)"
echo "   ComfyUI: $(test -d /workspace/ComfyUI && echo 'FOUND' || echo 'NOT FOUND')"
echo "   Volume: $(test -d /runpod-volume && echo 'MOUNTED' || echo 'NOT MOUNTED')"
echo ""
echo "============================================================================"
echo ""

echo "Symlinking files from Network Volume"
rm -rf /workspace && \
  ln -s /runpod-volume /workspace

echo "Starting ComfyUI API"
source /workspace/venv/bin/activate
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"
export PYTHONUNBUFFERED=true
export HF_HOME="/workspace"

# Set InSPyReNet background-removal model path to the model downloaded
# from Google drive into the Docker container
export TRANSPARENT_BACKGROUND_FILE_PATH=/root/.transparent-background

cd /workspace/ComfyUI

# Disable xformers for CUDA 12.8
EXTRA_ARGS=""
if [ "${CUDA_SHORT}" = "cu128" ]; then
    EXTRA_ARGS="--disable-xformers"
fi

python main.py --port 3000 --temp-directory /tmp \
  --database-url sqlite:////tmp/comfyui-serverless.db \
  ${EXTRA_ARGS} 2>&1 | tee /workspace/logs/comfyui-serverless.log &

deactivate

echo "Starting Runpod Handler"
"python${PYTHON_VERSION:-3}" -u /handler.py
