# IDM-VTON GPU Inference

Use a private GPU runtime for real tests. The local RTX 3050 4GB is not a good target for IDM-VTON SDXL inference.

## Prepared Local Files

Full prepared dataset:

```text
C:\USB_DressCode_Backup\DressCode
```

Small upper-body smoke-test zip:

```text
C:\USB_DressCode_Backup\DressCode_IDM_Eval20.zip
```

Local IDM-VTON clone:

```text
C:\USB_DressCode_Backup\IDM-VTON
```

## RunPod / Linux GPU Steps

On a GPU machine with 16GB+ VRAM:

```bash
cd /workspace
git clone https://github.com/yisol/IDM-VTON.git
cd IDM-VTON
conda env create -f environment.yaml
conda activate idm
pip install xformers
```

Upload and unzip `DressCode_IDM_Eval20.zip` into `/workspace`:

```bash
cd /workspace
unzip DressCode_IDM_Eval20.zip -d DressCode_IDM_Eval20
```

Run upper-body unpaired inference:

```bash
export IDM_VTON_DIR=/workspace/IDM-VTON
export DATA_DIR=/workspace/DressCode_IDM_Eval20
export CATEGORY=upper_body
export OUTPUT_DIR=/workspace/idm_results/upper_body_eval20
export TEST_BATCH_SIZE=1
export MIXED_PRECISION=fp16

bash /workspace/BerkAI/scripts/run-idm-dc-inference.sh
```

If you do not upload this repo to the GPU machine, copy the command from `scripts/run-idm-dc-inference.sh` and run it inside `/workspace/IDM-VTON`.

## Expected Output

For the 20-row eval subset, IDM-VTON should write generated images to:

```text
/workspace/idm_results/upper_body_eval20
```

Only after this smoke test passes should we run the full dataset:

```bash
export DATA_DIR=/workspace/DressCode
```

The full category test set has 1800 unpaired rows per category, so do not start it until the small eval run looks good.
