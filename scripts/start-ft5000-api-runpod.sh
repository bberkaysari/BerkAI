#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8888}"
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
AI_SERVICE_DIR="${AI_SERVICE_DIR:-${WORKSPACE_DIR}/BerkAI/ai-service}"

export TRYON_PROVIDER="${TRYON_PROVIDER:-local-warm}"
export TRYON_PUBLIC_BASE_URL="${TRYON_PUBLIC_BASE_URL:-http://localhost:${PORT}}"
export TRYON_RESULT_DIR="${TRYON_RESULT_DIR:-${AI_SERVICE_DIR}/outputs}"
export IDM_ROOT="${IDM_ROOT:-${WORKSPACE_DIR}/IDM-VTON}"
export IDM_TRYON_SCRIPT="${IDM_TRYON_SCRIPT:-${WORKSPACE_DIR}/run-idm-custom-tryon.py}"
export IDM_CHECKPOINT="${IDM_CHECKPOINT:-${WORKSPACE_DIR}/checkpoints/official_upper_2k_lr1e-6_steps5000/checkpoint-5000}"

cd "$AI_SERVICE_DIR"

python -m pip install -r requirements.txt
python -m pip install \
  accelerate==0.25.0 \
  torchmetrics==1.2.1 \
  tqdm==4.66.1 \
  transformers==4.36.2 \
  diffusers==0.25.0 \
  huggingface_hub==0.20.3 \
  einops==0.7.0 \
  scipy==1.11.1 \
  opencv-python==4.11.0.86 \
  gradio==4.24.0 \
  fvcore \
  cloudpickle \
  omegaconf \
  pycocotools \
  basicsr \
  av \
  onnxruntime==1.16.2

python -m uvicorn app.main:app --host 0.0.0.0 --port "$PORT" --workers 1
