# IDM-VTON Technical Plan

## Goal

Build a product-ready virtual try-on flow:

1. User uploads or captures a full-body/person photo.
2. User selects a catalog garment.
3. The AI service returns a realistic try-on image.
4. The ecommerce app stores and displays the result.

For the MVP, use IDM-VTON as an inference service. Do not fine-tune until we have a real-photo quality benchmark.

## Current Decision

Use IDM-VTON for upper-body try-on first.

Reasons:

- Smoke tests with DressCode unpaired inputs produced valid try-on images.
- It is closer to the target task than HR/HD/HR-VITON style warping pipelines.
- It has an existing DressCode/VITON-HD inference path.

Known constraints:

- Local RTX 3050 4GB VRAM is not enough for reliable IDM-VTON SDXL inference.
- Hugging Face Space is useful for quick tests, but has quota and privacy limits.
- Private customer photos should run on our own GPU runtime.

## MVP Architecture

```text
Frontend Next.js
  |
  | user photo + selected product id
  v
.NET WebAPI
  |
  | create try-on job
  | resolve product garment image
  v
AI Inference Service
  |
  | IDM-VTON on GPU
  v
Generated image storage
  |
  v
Frontend result view
```

## Services

### Frontend

- Product page has a "Try On" action.
- User uploads a person photo.
- Frontend sends the photo and `productId` to backend.
- UI polls job status or waits for a synchronous response in early MVP.

### Backend

Backend should own:

- authentication
- product lookup
- uploaded photo storage
- job creation
- calling AI inference service
- saving generated result URL/path

Do not call the AI service directly from the browser in production.

### AI Inference Service

FastAPI service with endpoints:

- `GET /health`
- `POST /try-on`

Suggested request shape:

```json
{
  "person_image_url": "https://...",
  "garment_image_url": "https://...",
  "garment_prompt": "black oversized hoodie",
  "category": "upper_body",
  "seed": 42,
  "steps": 30
}
```

Suggested response shape:

```json
{
  "status": "completed",
  "result_image_url": "https://...",
  "masked_image_url": "https://...",
  "duration_seconds": 18.2
}
```

## GPU Runtime

Recommended minimum for useful testing:

- NVIDIA GPU with 16GB+ VRAM
- CUDA runtime compatible with PyTorch
- `test_batch_size=1`
- `mixed_precision=fp16`

Good options:

- RunPod A10/A4000/A5000
- Colab Pro L4/A100
- Lambda Labs or similar GPU VM

Avoid using public Hugging Face Space for private photos.

## Dataset Strategy

Keep the raw DressCode dataset unchanged except for generated IDM helper assets:

```text
C:\USB_DressCode_Backup\DressCode
```

Generated IDM assets live inside each category:

```text
C:\USB_DressCode_Backup\DressCode\upper_body\image-densepose
C:\USB_DressCode_Backup\DressCode\upper_body\dc_caption.txt
```

Initial benchmark:

- 20 DressCode upper-body unpaired examples
- 20 real phone photos
- 20 product garment photos

Evaluate before any fine-tuning.

## Quality Checklist

For each result, score 1-5:

- garment identity preserved
- user identity/body preserved
- arms/hands acceptable
- neckline/shoulders acceptable
- pattern/logo/detail preserved
- commercial usability

Fine-tuning only makes sense if base IDM-VTON is close but inconsistent. If base outputs are bad, fix input quality, masking, prompts, or photo constraints first.

## Immediate Next Steps

1. Collect a small real-photo benchmark.
2. Run public Space only with non-private images.
3. Set up private GPU runtime for real user photos.
4. Wrap IDM-VTON with a FastAPI inference service.
5. Integrate backend job flow into the ecommerce app.
