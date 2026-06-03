#!/usr/bin/env bash
set -euo pipefail

IDM_REPO="${IDM_REPO:-/workspace/IDM-VTON}"
DATASET_ROOT="${DATASET_ROOT:-/workspace/DressCode_IDM_Train_2K}"
CATEGORY="${CATEGORY:-upper_body}"
DATA_DIR="${DATA_DIR:-${DATASET_ROOT}/${CATEGORY}}"
OUTPUT_DIR="${OUTPUT_DIR:-/workspace/idm_outputs/dresscode_${CATEGORY}}"
IP_ADAPTER_DIR="${IP_ADAPTER_DIR:-/workspace/IP-Adapter}"
PRETRAINED_MODEL_NAME_OR_PATH="${PRETRAINED_MODEL_NAME_OR_PATH:-diffusers/stable-diffusion-xl-1.0-inpainting-0.1}"
PRETRAINED_GARMENTNET_PATH="${PRETRAINED_GARMENTNET_PATH:-stabilityai/stable-diffusion-xl-base-1.0}"
PRETRAINED_GARMENTNET_SUBFOLDER="${PRETRAINED_GARMENTNET_SUBFOLDER:-unet}"
PRETRAINED_IP_ADAPTER_PATH="${PRETRAINED_IP_ADAPTER_PATH:-${IP_ADAPTER_DIR}/sdxl_models/ip-adapter-plus_sdxl_vit-h.bin}"
IMAGE_ENCODER_PATH="${IMAGE_ENCODER_PATH:-${IP_ADAPTER_DIR}/models/image_encoder}"
IMAGE_ENCODER_SUBFOLDER="${IMAGE_ENCODER_SUBFOLDER:-}"

TRAIN_BATCH_SIZE="${TRAIN_BATCH_SIZE:-2}"
TEST_BATCH_SIZE="${TEST_BATCH_SIZE:-1}"
GRAD_ACCUM_STEPS="${GRAD_ACCUM_STEPS:-4}"
MAX_TRAIN_STEPS="${MAX_TRAIN_STEPS:-10000}"
CHECKPOINTING_STEPS="${CHECKPOINTING_STEPS:-1000}"
LOGGING_STEPS="${LOGGING_STEPS:-50}"
VALIDATION_STEPS="${VALIDATION_STEPS:-500}"
VALIDATION_SAMPLES="${VALIDATION_SAMPLES:-1}"
LEARNING_RATE="${LEARNING_RATE:-1e-5}"
MIXED_PRECISION="${MIXED_PRECISION:-fp16}"
HEIGHT="${HEIGHT:-1024}"
WIDTH="${WIDTH:-768}"
TRAIN_NUM_WORKERS="${TRAIN_NUM_WORKERS:-0}"
TEST_NUM_WORKERS="${TEST_NUM_WORKERS:-0}"
USE_8BIT_ADAM="${USE_8BIT_ADAM:-1}"
ENABLE_XFORMERS="${ENABLE_XFORMERS:-0}"
DISABLE_VALIDATION="${DISABLE_VALIDATION:-1}"

cd "${IDM_REPO}"

EXTRA_ARGS=()
if [[ "${USE_8BIT_ADAM}" == "1" ]]; then
  EXTRA_ARGS+=(--use_8bit_adam)
fi
if [[ "${ENABLE_XFORMERS}" == "1" ]]; then
  EXTRA_ARGS+=(--enable_xformers_memory_efficient_attention)
fi
if [[ "${DISABLE_VALIDATION}" == "1" ]]; then
  EXTRA_ARGS+=(--disable_validation)
fi
if [[ -n "${IMAGE_ENCODER_SUBFOLDER}" ]]; then
  EXTRA_ARGS+=(--image_encoder_subfolder "${IMAGE_ENCODER_SUBFOLDER}")
fi

accelerate launch train_xl.py \
  --gradient_checkpointing \
  "${EXTRA_ARGS[@]}" \
  --mixed_precision "${MIXED_PRECISION}" \
  --height "${HEIGHT}" \
  --width "${WIDTH}" \
  --output_dir "${OUTPUT_DIR}" \
  --data_dir "${DATA_DIR}" \
  --train_batch_size "${TRAIN_BATCH_SIZE}" \
  --test_batch_size "${TEST_BATCH_SIZE}" \
  --train_num_workers "${TRAIN_NUM_WORKERS}" \
  --test_num_workers "${TEST_NUM_WORKERS}" \
  --gradient_accumulation_steps "${GRAD_ACCUM_STEPS}" \
  --max_train_steps "${MAX_TRAIN_STEPS}" \
  --checkpointing_epoch "${CHECKPOINTING_STEPS}" \
  --logging_steps "${LOGGING_STEPS}" \
  --validation_steps "${VALIDATION_STEPS}" \
  --validation_samples "${VALIDATION_SAMPLES}" \
  --learning_rate "${LEARNING_RATE}" \
  --pretrained_model_name_or_path "${PRETRAINED_MODEL_NAME_OR_PATH}" \
  --pretrained_garmentnet_path "${PRETRAINED_GARMENTNET_PATH}" \
  --pretrained_garmentnet_subfolder "${PRETRAINED_GARMENTNET_SUBFOLDER}" \
  --pretrained_ip_adapter_path "${PRETRAINED_IP_ADAPTER_PATH}" \
  --image_encoder_path "${IMAGE_ENCODER_PATH}"
