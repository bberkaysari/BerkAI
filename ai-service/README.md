# BerkAI Try-On AI Service

FastAPI wrapper for the virtual try-on model.

## Current MVP Mode

The first implementation can call the public IDM-VTON Hugging Face Space for non-private smoke tests.

Do not use public Space mode for private customer photos.

## Target Production Mode

Run IDM-VTON locally on a private GPU server and expose the same API shape:

- `GET /health`
- `POST /warmup`
- `POST /try-on`

For the FT5000 checkpoint, run the service on a GPU pod with:

```bash
cd /workspace/BerkAI
bash scripts/start-ft5000-api-runpod.sh
```

The script defaults to `TRYON_PROVIDER=local-warm`, which loads FT5000 once
inside the FastAPI process instead of reloading the full model for every
request. After the API starts, warm the model once:

```bash
curl -X POST http://127.0.0.1:8888/warmup
```

Then point the frontend at the pod URL with `NEXT_PUBLIC_AI_SERVICE_URL`.

The current local laptop cannot run FT5000 inference because it has 4GB VRAM.
Use local mode only for API/UI wiring or public Space smoke tests.

## Setup

```powershell
cd ai-service
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\uvicorn.exe app.main:app --host 0.0.0.0 --port 8010
```

## Smoke Test Endpoint

```powershell
curl.exe -X POST http://localhost:8010/try-on `
  -F "person=@C:\path\person.jpg" `
  -F "garment=@C:\path\garment.jpg" `
  -F "prompt=black oversized hoodie"
```

The response includes local paths for the generated result files.
It also includes browser-readable `result_image_url` and `masked_image_url` fields.
