# IDM-VTON DressCode Training

## Local dataset paths

Raw DressCode:

```text
C:\USB_DressCode_Backup\DressCode
```

IDM inference-compatible DressCode:

```text
C:\USB_DressCode_Backup\DressCode
```

`train_xl.py` compatible full training views:

```text
C:\USB_DressCode_Backup\DressCode_IDM_Train\upper_body
C:\USB_DressCode_Backup\DressCode_IDM_Train\lower_body
C:\USB_DressCode_Backup\DressCode_IDM_Train\dresses
```

Current full training views:

```text
upper_body: train 13563, test 1800
lower_body: train 7151, test 1800
dresses: train 27678, test 1800
```

First-run 2K training views:

```text
C:\USB_DressCode_Backup\DressCode_IDM_Train_2K\upper_body
C:\USB_DressCode_Backup\DressCode_IDM_Train_2K\lower_body
C:\USB_DressCode_Backup\DressCode_IDM_Train_2K\dresses
each category: train 2000, test 200
combined apparent size: ~1.54 GB
```

Recommended first upload package:

```text
C:\USB_DressCode_Backup\DressCode_IDM_Train_2K.tar
size: ~1.67 GB
```

The training view uses this structure:

```text
upper_body/
  train_pairs.txt
  test_pairs.txt
  train/
    image/
    cloth/
    image-densepose/
    agnostic-mask/
    vitonhd_train_tagged.json
  test/
    image/
    cloth/
    image-densepose/
    agnostic-mask/
    vitonhd_test_tagged.json
```

## Rebuild Training Dataset

```powershell
& 'C:\USB_DressCode_Backup\IDM-VTON\.venv\Scripts\python.exe' `
  .\scripts\create_idm_dresscode_train_view.py `
  --source-root 'C:\USB_DressCode_Backup\DressCode' `
  --output-root 'C:\USB_DressCode_Backup\DressCode_IDM_Train' `
  --category upper_body `
  --workers 12 `
  --force
```

## RunPod Training Flow

Copy these to the pod:

```text
C:\USB_DressCode_Backup\IDM-VTON
C:\USB_DressCode_Backup\DressCode_IDM_Train_2K.tar
scripts/setup-idm-training-ckpts.sh
scripts/setup-idm-training-env.sh
scripts/run-idm-dc-train.sh
```

Expected pod layout:

```text
/workspace/IDM-VTON
/workspace/DressCode_IDM_Train_2K/{upper_body,lower_body,dresses}
/workspace/scripts/setup-idm-training-ckpts.sh
/workspace/scripts/setup-idm-training-env.sh
/workspace/scripts/run-idm-dc-train.sh
```

Extract the dataset package:

```bash
tar -xf /workspace/DressCode_IDM_Train_2K.tar -C /workspace
```

Install the training checkpoint dependencies:

```bash
bash /workspace/scripts/setup-idm-training-env.sh
bash /workspace/scripts/setup-idm-training-ckpts.sh
```

Start training:

```bash
bash /workspace/scripts/run-idm-dc-train.sh
```

Train another category:

```bash
CATEGORY=lower_body bash /workspace/scripts/run-idm-dc-train.sh
CATEGORY=dresses bash /workspace/scripts/run-idm-dc-train.sh
```

Useful overrides:

```bash
MAX_TRAIN_STEPS=2000 CHECKPOINTING_STEPS=500 TRAIN_BATCH_SIZE=1 GRAD_ACCUM_STEPS=8 \
  bash /workspace/scripts/run-idm-dc-train.sh
```

The first smoke run disables validation inference by default. To generate validation samples during training:

```bash
DISABLE_VALIDATION=0 VALIDATION_STEPS=500 VALIDATION_SAMPLES=1 \
  bash /workspace/scripts/run-idm-dc-train.sh
```

`xformers` is off by default to keep the first environment setup less brittle. If your pod has xformers installed:

```bash
ENABLE_XFORMERS=1 bash /workspace/scripts/run-idm-dc-train.sh
```

To train from the full dataset later:

```bash
DATASET_ROOT=/workspace/DressCode_IDM_Train CATEGORY=upper_body \
  bash /workspace/scripts/run-idm-dc-train.sh
```

Use a 24 GB+ NVIDIA GPU for the first real run. Local RTX 3050 Ti is useful for smoke tests, not training.
