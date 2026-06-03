#!/usr/bin/env bash
set -euo pipefail

export HF_HOME="${HF_HOME:-/workspace/hf_cache}"
export HF_HUB_ENABLE_HF_TRANSFER="${HF_HUB_ENABLE_HF_TRANSFER:-1}"
export PYTHONUNBUFFERED="${PYTHONUNBUFFERED:-1}"
export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-max_split_size_mb:256}"

cd /workspace/IDM-VTON

python -u train_xl.py \
  --gradient_checkpointing \
  --use_8bit_adam \
  --mixed_precision fp16 \
  --height 512 \
  --width 384 \
  --output_dir /workspace/idm_outputs/smoke_upper_512 \
  --data_dir /workspace/DressCode_IDM_Train_2K/upper_body \
  --train_batch_size 1 \
  --test_batch_size 1 \
  --train_num_workers 0 \
  --test_num_workers 0 \
  --max_train_steps 1 \
  --checkpointing_epoch 999999 \
  --logging_steps 1 \
  --disable_validation \
  --pretrained_ip_adapter_path /workspace/IP-Adapter/sdxl_models/ip-adapter-plus_sdxl_vit-h.bin \
  --image_encoder_path /workspace/IP-Adapter/models/image_encoder
