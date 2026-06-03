# BerkAI IDM-VTON Execution Plan

Date: 2026-05-26

## Current State

- RunPod active pod count: 0
- RunPod current GPU spend per hour: 0
- Local DressCode data and generated comparison outputs are still available.
- Official IDM-VTON (`yisol/IDM-VTON`) produced good try-on results.
- Our SDXL-base training runs produced worse results than official IDM-VTON.
- Official-start fine-tunes completed at 500 and 2000 steps.
- 500-step and 2000-step outputs are close to official IDM-VTON; neither clearly beats official on the fixed unpaired comparison.

## Decisions

1. Production baseline is official `yisol/IDM-VTON`.
2. Do not continue SDXL-base full fine-tuning.
3. Do not run expensive blind 5k/10k step experiments.
4. Training is still a goal, but only as controlled fine-tuning from official IDM-VTON.
5. App/MVP work should not wait for training success.

## Checkpoint Storage Policy

Do not download every checkpoint locally by default.

Reason: a full IDM checkpoint is about 19 GB. The current C: drive has limited free space, so keeping every experiment locally will fill disk quickly.

Local machine currently keeps:

- generated result images,
- comparison sheets,
- training and inference scripts,
- dataset tar files.

Remote RunPod volumes may still contain full checkpoints:

- `checkpoint-500`: `/workspace/idm_outputs/official_upper_2k_lr1e-6_steps500/checkpoint-500`
- `checkpoint-2000`: `/workspace/idm_outputs/official_upper_2k_lr1e-6_steps2000/checkpoint-2000`

Only download a full checkpoint locally if it is a clear keeper. If a checkpoint does not beat official IDM-VTON, delete its remote pod/volume after saving result images.

Recommended local keeper, if one must be archived now:

- Prefer `checkpoint-500` over `checkpoint-2000`, because it preserves official quality with less overfit risk.
- Do not archive `checkpoint-2000` unless later tests show a clear advantage.

## Immediate Next Step

Stop blind step increases. The next useful work is data/evaluation quality.

Progress on 2026-05-26:

- Fixed 20-sample upper-body unpaired eval set created.
- Official IDM-VTON baseline has been run and downloaded locally.
- Official eval outputs: `C:\USB_DressCode_Backup\RunPod_Results\eval20_upper_unpaired\official_outputs`
- Official contact sheet: `C:\USB_DressCode_Backup\RunPod_Results\eval20_upper_unpaired\eval20_official_contact_sheet.jpg`
- Corrected official contact sheet using the actual `test/cloth` inference inputs: `C:\USB_DressCode_Backup\RunPod_Results\eval20_upper_unpaired\eval20_official_contact_sheet_REAL_INPUTS.jpg`
- Ignore the older contact sheet for quality decisions; its middle column used a separate `cloth_target` folder, not the exact cloth images read by `inference.py`.
- Temporary official eval RunPod pod was stopped and deleted after downloading outputs.
- FT500 and FT2000 eval are pending because their stopped checkpoint pods currently fail to start with RunPod host GPU availability errors.
- FT2000 pod was retried multiple times on 2026-05-26 and still failed with `There are not enough free GPUs on the host machine to start this pod.`
- A corrected 4-sample comparison using the actual `test/cloth` inputs is available here: `C:\USB_DressCode_Backup\RunPod_Results\upper_unpaired_ft2000_test\compare_4sample_REAL_INPUTS_official_ft500_ft2000.jpg`
- Official-start 5000-step fine-tune completed on RunPod pod `8d4avmwhq0h21a`.
- Local FT5000 checkpoint path: `C:\USB_DressCode_Backup\RunPod_Checkpoints\official_upper_2k_lr1e-6_steps5000\checkpoint-5000`
- FT5000 local verification: 23 files, 20,160,121,893 bytes, 18.78 GB. Remote and local byte totals matched before the pod was stopped.
- The FT5000 pod was stopped after download. It was not deleted, so its remote volume still exists and may contribute to storage spend.
- FT5000 was evaluated on the fixed 20-sample upper-body unpaired set.
- FT5000 outputs: `C:\USB_DressCode_Backup\RunPod_Results\eval20_upper_unpaired\ft5000_outputs`
- Official-vs-FT5000 comparison sheet: `C:\USB_DressCode_Backup\RunPod_Results\eval20_upper_unpaired\compare_eval20_REAL_INPUTS_official_vs_ft5000.jpg`
- Visual conclusion: FT5000 is very close to official IDM-VTON and does not show a clear, consistent improvement on the 20-sample set.

Remaining:

1. Start the FT500 and FT2000 checkpoint pods when RunPod has GPU capacity on those hosts.
2. Run the same 20-sample unpaired eval set on FT500 and FT2000.
3. Create a single official-vs-FT500-vs-FT2000 comparison sheet.
4. Keep training only if a candidate consistently beats official.
5. If training continues, use a more targeted subset instead of simply raising steps.

## Success Criteria

The fine-tuned `checkpoint-500` must be compared against official IDM-VTON on the same 4 examples.

Continue only if:

- color shift is not worse than official,
- background/person are not degraded,
- garment detail is equal or better,
- output does not become darker/purple,
- fit is at least as good as official.

Stop if:

- output is darker,
- official result is clearly better,
- garment patterns are lost,
- person/background gets damaged.

## Product Track

In parallel, build the MVP around official IDM-VTON:

1. Upload/select person image.
2. Upload/select garment image.
3. Run preprocess.
4. Run official IDM-VTON inference.
5. Save output.

Training improvements can be plugged in later only if they beat official baseline.

## Local Result Folders

- `C:\USB_DressCode_Backup\RunPod_Results\upper_checkpoint200_test`
- `C:\USB_DressCode_Backup\RunPod_Results\upper_checkpoint2000_test`
- `C:\USB_DressCode_Backup\RunPod_Results\upper_official_idm_test`
- `C:\USB_DressCode_Backup\RunPod_Results\upper_official_ft500_test`
- `C:\USB_DressCode_Backup\RunPod_Results\upper_unpaired_official_test`
- `C:\USB_DressCode_Backup\RunPod_Results\upper_unpaired_ft500_test`
- `C:\USB_DressCode_Backup\RunPod_Results\upper_unpaired_ft2000_test`
