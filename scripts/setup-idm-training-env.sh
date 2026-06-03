#!/usr/bin/env bash
set -euo pipefail

python -m pip install --upgrade pip

python -m pip install \
  numpy==1.26.4 \
  accelerate==0.25.0 \
  transformers==4.36.2 \
  diffusers==0.25.0 \
  huggingface_hub==0.20.2 \
  einops==0.7.0 \
  scipy==1.11.1 \
  opencv-python-headless==4.8.1.78 \
  packaging==23.2 \
  tqdm==4.66.1 \
  omegaconf==2.3.0 \
  fvcore==0.1.5.post20221221 \
  cloudpickle==3.0.0 \
  onnxruntime==1.16.2 \
  torchmetrics==1.2.1 \
  pycocotools \
  basicsr

python -m pip install --index-url https://download.pytorch.org/whl/cu121 \
  torch==2.2.0+cu121 \
  torchvision==0.17.0+cu121 \
  torchaudio==2.2.0+cu121

python -m pip install --no-deps bitsandbytes==0.43.1

python - <<'PY'
import torch
print("torch", torch.__version__)
print("cuda", torch.cuda.is_available())
print("gpu", torch.cuda.get_device_name(0) if torch.cuda.is_available() else None)
PY

echo "Training Python environment is ready."
