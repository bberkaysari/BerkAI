from __future__ import annotations

import gc
import sys
from pathlib import Path

import torch


IDM_ROOT = Path(r"C:\USB_DressCode_Backup\IDM-VTON")
UNET_ROOT = Path(
    r"C:\Users\Berkay\.cache\huggingface\hub"
    r"\models--yisol--IDM-VTON-DC\snapshots"
    r"\0fcf915a04a97a353678e2f17f89587127fce7f0"
)

sys.path.insert(0, str(IDM_ROOT))

from src.unet_hacked_tryon import UNet2DConditionModel  # noqa: E402


def log(*parts: object) -> None:
    print(*parts, flush=True)


def cuda_status(label: str) -> None:
    if not torch.cuda.is_available():
        log(label, "cuda_available=False")
        return
    free, total = torch.cuda.mem_get_info()
    log(
        label,
        f"free_mb={round(free / 1024**2)}",
        f"used_mb={round((total - free) / 1024**2)}",
        f"total_mb={round(total / 1024**2)}",
    )


def main() -> None:
    log("torch", torch.__version__)
    log("cuda_available", torch.cuda.is_available())
    if torch.cuda.is_available():
        log("device", torch.cuda.get_device_name(0))
    cuda_status("before")

    log("loading_unet_cpu", UNET_ROOT)
    unet = UNet2DConditionModel.from_pretrained(
        str(UNET_ROOT),
        subfolder="unet",
        torch_dtype=torch.float16,
    )
    params_mb = sum(p.numel() * p.element_size() for p in unet.parameters()) / 1024**2
    log("unet_param_mb", round(params_mb))
    cuda_status("after_cpu_load")

    log("moving_unet_to_cuda")
    unet.to("cuda")
    torch.cuda.synchronize()
    cuda_status("after_cuda_move")

    del unet
    gc.collect()
    torch.cuda.empty_cache()
    cuda_status("after_cleanup")
    log("ok")


if __name__ == "__main__":
    main()
