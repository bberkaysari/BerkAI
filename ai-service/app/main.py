from __future__ import annotations

import json
import os
import subprocess
import asyncio
import threading
import time
import uuid
from pathlib import Path
from typing import Any

import httpx
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel


SPACE_ROOT = "https://yisol-idm-vton.hf.space"
RESULT_DIR = Path(os.getenv("TRYON_RESULT_DIR", "outputs"))
PROVIDER = os.getenv("TRYON_PROVIDER", "hf-space")
PUBLIC_BASE_URL = os.getenv("TRYON_PUBLIC_BASE_URL", "http://localhost:8010")
_warm_runner: Any | None = None
_warm_runner_guard = threading.Lock()

app = FastAPI(title="BerkAI Try-On AI Service", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

RESULT_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/outputs", StaticFiles(directory=str(RESULT_DIR)), name="outputs")


class TryOnResponse(BaseModel):
    status: str
    result_image_path: str
    result_image_url: str
    masked_image_path: str | None = None
    masked_image_url: str | None = None
    duration_seconds: float
    provider: str


@app.get("/health")
async def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "provider": PROVIDER,
        "model_loaded": bool(getattr(_warm_runner, "is_loaded", False)),
    }


@app.post("/warmup")
async def warmup() -> dict[str, Any]:
    if PROVIDER != "local-warm":
        return {"status": "skipped", "provider": PROVIDER, "model_loaded": False}

    started = time.perf_counter()
    await asyncio.to_thread(_get_warm_runner, True)
    return {
        "status": "ready",
        "provider": PROVIDER,
        "model_loaded": True,
        "duration_seconds": round(time.perf_counter() - started, 2),
    }


@app.post("/try-on", response_model=TryOnResponse)
async def try_on(
    person: UploadFile = File(...),
    garment: UploadFile = File(...),
    prompt: str = Form("upper body garment"),
    steps: int = Form(30),
    seed: int = Form(42),
    auto_mask: bool = Form(True),
    auto_crop: bool = Form(False),
) -> TryOnResponse:
    started = time.perf_counter()
    job_id = uuid.uuid4().hex[:12]
    job_dir = RESULT_DIR / job_id
    job_dir.mkdir(parents=True, exist_ok=True)

    person_path = job_dir / _clean_filename(person.filename or "person.jpg")
    garment_path = job_dir / _clean_filename(garment.filename or "garment.jpg")

    await _save_upload(person, person_path)
    await _save_upload(garment, garment_path)

    try:
        if PROVIDER == "local-warm":
            result_path, masked_path = await _run_warm_local_tryon(
                person_path=person_path,
                garment_path=garment_path,
                prompt=prompt,
                steps=steps,
                seed=seed,
                auto_mask=auto_mask,
                auto_crop=auto_crop,
                output_dir=job_dir,
            )
        elif PROVIDER == "local-script":
            result_path, masked_path = await _run_local_script_tryon(
                person_path=person_path,
                garment_path=garment_path,
                prompt=prompt,
                steps=steps,
                seed=seed,
                auto_mask=auto_mask,
                auto_crop=auto_crop,
                output_dir=job_dir,
            )
        elif PROVIDER == "hf-space":
            result_path, masked_path = await _run_hf_space_tryon(
                person_path=person_path,
                garment_path=garment_path,
                prompt=prompt,
                steps=steps,
                seed=seed,
                auto_mask=auto_mask,
                auto_crop=auto_crop,
                output_dir=job_dir,
            )
        else:
            raise RuntimeError(f"Unsupported TRYON_PROVIDER: {PROVIDER}")
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    return TryOnResponse(
        status="completed",
        result_image_path=str(result_path),
        result_image_url=_public_output_url(result_path),
        masked_image_path=str(masked_path) if masked_path else None,
        masked_image_url=_public_output_url(masked_path) if masked_path else None,
        duration_seconds=round(time.perf_counter() - started, 2),
        provider=PROVIDER,
    )


async def _save_upload(upload: UploadFile, path: Path) -> None:
    with path.open("wb") as file:
        while chunk := await upload.read(1024 * 1024):
            file.write(chunk)


def _clean_filename(filename: str) -> str:
    return Path(filename).name.replace(" ", "_")


async def _run_hf_space_tryon(
    *,
    person_path: Path,
    garment_path: Path,
    prompt: str,
    steps: int,
    seed: int,
    auto_mask: bool,
    auto_crop: bool,
    output_dir: Path,
) -> tuple[Path, Path | None]:
    async with httpx.AsyncClient(timeout=httpx.Timeout(300.0)) as client:
        person_remote = await _upload_to_space(client, person_path)
        garment_remote = await _upload_to_space(client, garment_path)

        session_hash = "berkai" + uuid.uuid4().hex[:10]
        payload = {
            "data": [
                {
                    "background": _file_data(person_remote, person_path.name),
                    "layers": [],
                    "composite": None,
                },
                _file_data(garment_remote, garment_path.name),
                prompt,
                auto_mask,
                auto_crop,
                steps,
                seed,
            ],
            "event_data": None,
            "fn_index": 2,
            "trigger_id": 25,
            "session_hash": session_hash,
        }

        join_response = await client.post(
            f"{SPACE_ROOT}/queue/join",
            json=payload,
        )
        join_response.raise_for_status()

        completed = await _wait_for_space_result(client, session_hash)
        if not completed.get("success"):
            raise RuntimeError(json.dumps(completed.get("output"), ensure_ascii=False))

        output_data: list[dict[str, Any]] = completed["output"]["data"]
        result_url = output_data[0]["url"]
        masked_url = output_data[1]["url"] if len(output_data) > 1 else None

        result_path = output_dir / "tryon.png"
        masked_path = output_dir / "masked.png" if masked_url else None

        await _download_file(client, result_url, result_path)
        if masked_url and masked_path:
            await _download_file(client, masked_url, masked_path)

        return result_path, masked_path


async def _run_local_script_tryon(
    *,
    person_path: Path,
    garment_path: Path,
    prompt: str,
    steps: int,
    seed: int,
    auto_mask: bool,
    auto_crop: bool,
    output_dir: Path,
) -> tuple[Path, Path | None]:
    script_path = Path(os.getenv("IDM_TRYON_SCRIPT", "/workspace/run-idm-custom-tryon.py"))
    idm_root = Path(os.getenv("IDM_ROOT", "/workspace/IDM-VTON"))
    checkpoint = Path(
        os.getenv(
            "IDM_CHECKPOINT",
            "/workspace/checkpoints/official_upper_2k_lr1e-6_steps5000/checkpoint-5000",
        )
    )

    if not script_path.exists():
        raise RuntimeError(f"IDM try-on script was not found: {script_path}")
    if not idm_root.exists():
        raise RuntimeError(f"IDM-VTON repo was not found: {idm_root}")
    if not checkpoint.exists():
        raise RuntimeError(f"IDM checkpoint was not found: {checkpoint}")

    command = [
        "python",
        str(script_path),
        "--idm-root",
        str(idm_root),
        "--checkpoint",
        str(checkpoint),
        "--person",
        str(person_path),
        "--garment",
        str(garment_path),
        "--prompt",
        prompt,
        "--output-dir",
        str(output_dir),
        "--category",
        "upper_body",
        "--steps",
        str(steps),
        "--seed",
        str(seed),
    ]
    if auto_mask:
        command.append("--auto-mask")
    if auto_crop:
        command.append("--auto-crop")

    process = await _run_subprocess(command)
    if process.returncode != 0:
        raise RuntimeError(
            "IDM local script failed.\n"
            f"STDOUT:\n{process.stdout}\n\n"
            f"STDERR:\n{process.stderr}"
        )

    result_path = output_dir / "tryon_ft5000.png"
    masked_path = output_dir / "masked_ft5000.png"
    if not result_path.exists():
        raise RuntimeError(f"IDM result was not created: {result_path}")
    return result_path, masked_path if masked_path.exists() else None


async def _run_warm_local_tryon(
    *,
    person_path: Path,
    garment_path: Path,
    prompt: str,
    steps: int,
    seed: int,
    auto_mask: bool,
    auto_crop: bool,
    output_dir: Path,
) -> tuple[Path, Path | None]:
    return await asyncio.to_thread(
        _run_warm_local_tryon_sync,
        person_path,
        garment_path,
        prompt,
        steps,
        seed,
        auto_mask,
        auto_crop,
        output_dir,
    )


def _run_warm_local_tryon_sync(
    person_path: Path,
    garment_path: Path,
    prompt: str,
    steps: int,
    seed: int,
    auto_mask: bool,
    auto_crop: bool,
    output_dir: Path,
) -> tuple[Path, Path | None]:
    runner = _get_warm_runner(load=True)
    return runner.run(
        person_path=person_path,
        garment_path=garment_path,
        prompt=prompt,
        output_dir=output_dir,
        steps=steps,
        seed=seed,
        auto_mask=auto_mask,
        auto_crop=auto_crop,
    )


def _get_warm_runner(load: bool = False) -> Any:
    global _warm_runner

    with _warm_runner_guard:
        if _warm_runner is None:
            from app.idm_warm_runner import IDMWarmRunner

            idm_root = Path(os.getenv("IDM_ROOT", "/workspace/IDM-VTON"))
            checkpoint = Path(
                os.getenv(
                    "IDM_CHECKPOINT",
                    "/workspace/checkpoints/official_upper_2k_lr1e-6_steps5000/checkpoint-5000",
                )
            )
            device = os.getenv("IDM_DEVICE") or None
            _warm_runner = IDMWarmRunner(
                idm_root=idm_root,
                checkpoint=checkpoint,
                device=device,
            )

        if load:
            _warm_runner.load()

        return _warm_runner


async def _run_subprocess(command: list[str]) -> subprocess.CompletedProcess[str]:
    import asyncio

    return await asyncio.to_thread(
        subprocess.run,
        command,
        capture_output=True,
        text=True,
        check=False,
    )


async def _upload_to_space(client: httpx.AsyncClient, path: Path) -> str:
    with path.open("rb") as file:
        response = await client.post(
            f"{SPACE_ROOT}/upload",
            files={"files": (path.name, file, "image/jpeg")},
        )
    response.raise_for_status()
    data = response.json()
    if not data:
        raise RuntimeError("Hugging Face Space upload returned an empty response.")
    return data[0]


def _file_data(path: str, name: str) -> dict[str, Any]:
    return {
        "path": path,
        "orig_name": name,
        "mime_type": "image/jpeg",
        "meta": {"_type": "gradio.FileData"},
    }


async def _wait_for_space_result(
    client: httpx.AsyncClient,
    session_hash: str,
) -> dict[str, Any]:
    async with client.stream(
        "GET",
        f"{SPACE_ROOT}/queue/data",
        params={"session_hash": session_hash},
    ) as response:
        response.raise_for_status()
        async for line in response.aiter_lines():
            if not line.startswith("data: "):
                continue
            payload = json.loads(line.removeprefix("data: "))
            if payload.get("msg") == "process_completed":
                return payload
            if payload.get("msg") == "close_stream":
                break

    raise RuntimeError("Hugging Face Space stream closed before completion.")


async def _download_file(client: httpx.AsyncClient, url: str, path: Path) -> None:
    response = await client.get(url)
    response.raise_for_status()
    path.write_bytes(response.content)


def _public_output_url(path: Path) -> str:
    relative = path.resolve().relative_to(RESULT_DIR.resolve()).as_posix()
    return f"{PUBLIC_BASE_URL.rstrip('/')}/outputs/{relative}"
