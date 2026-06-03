#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${ROOT_DIR:-/workspace}"
IP_ADAPTER_DIR="${IP_ADAPTER_DIR:-${ROOT_DIR}/IP-Adapter}"

mkdir -p "${IP_ADAPTER_DIR}"

huggingface-cli download h94/IP-Adapter \
  sdxl_models/ip-adapter-plus_sdxl_vit-h.bin \
  --local-dir "${IP_ADAPTER_DIR}" \
  --local-dir-use-symlinks False

huggingface-cli download h94/IP-Adapter \
  models/image_encoder/config.json \
  models/image_encoder/model.safetensors \
  --local-dir "${IP_ADAPTER_DIR}" \
  --local-dir-use-symlinks False

echo "IP-Adapter checkpoint: ${IP_ADAPTER_DIR}/sdxl_models/ip-adapter-plus_sdxl_vit-h.bin"
echo "Image encoder: ${IP_ADAPTER_DIR}/models/image_encoder"
