#!/usr/bin/env bash
set -euo pipefail

IDM_VTON_DIR="${IDM_VTON_DIR:-/workspace/IDM-VTON}"
DATA_DIR="${DATA_DIR:-/workspace/DressCode_IDM_Eval20}"
CATEGORY="${CATEGORY:-upper_body}"
OUTPUT_DIR="${OUTPUT_DIR:-/workspace/idm_results/${CATEGORY}}"
SEED="${SEED:-42}"
STEPS="${STEPS:-30}"
GUIDANCE_SCALE="${GUIDANCE_SCALE:-2.0}"
TEST_BATCH_SIZE="${TEST_BATCH_SIZE:-1}"
MIXED_PRECISION="${MIXED_PRECISION:-fp16}"
WIDTH="${WIDTH:-768}"
HEIGHT="${HEIGHT:-1024}"

mkdir -p "${OUTPUT_DIR}"
cd "${IDM_VTON_DIR}"

accelerate launch inference_dc.py \
  --width "${WIDTH}" \
  --height "${HEIGHT}" \
  --num_inference_steps "${STEPS}" \
  --output_dir "${OUTPUT_DIR}" \
  --unpaired \
  --data_dir "${DATA_DIR}" \
  --seed "${SEED}" \
  --test_batch_size "${TEST_BATCH_SIZE}" \
  --guidance_scale "${GUIDANCE_SCALE}" \
  --category "${CATEGORY}" \
  --mixed_precision "${MIXED_PRECISION}" \
  --enable_xformers_memory_efficient_attention
