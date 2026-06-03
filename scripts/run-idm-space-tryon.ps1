param(
    [Parameter(Mandatory = $true)]
    [string]$PersonImage,

    [Parameter(Mandatory = $true)]
    [string]$GarmentImage,

    [Parameter(Mandatory = $true)]
    [string]$Prompt,

    [string]$OutputDir = "C:\USB_DressCode_Backup\DressCode\_idm_results",
    [int]$Steps = 30,
    [int]$Seed = 42,
    [bool]$AutoMask = $true,
    [bool]$AutoCrop = $false
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    throw "curl.exe was not found on PATH."
}

if (-not (Test-Path -LiteralPath $PersonImage)) {
    throw "Person image not found: $PersonImage"
}

if (-not (Test-Path -LiteralPath $GarmentImage)) {
    throw "Garment image not found: $GarmentImage"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$spaceRoot = "https://yisol-idm-vton.hf.space"
$session = "codex" + ([guid]::NewGuid().ToString("N").Substring(0, 10))
$personName = Split-Path -Leaf $PersonImage
$garmentName = Split-Path -Leaf $GarmentImage
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "Uploading person image..."
$personUpload = (& curl.exe -s -X POST -F "files=@$PersonImage" "$spaceRoot/upload" | ConvertFrom-Json)[0]

Write-Host "Uploading garment image..."
$garmentUpload = (& curl.exe -s -X POST -F "files=@$GarmentImage" "$spaceRoot/upload" | ConvertFrom-Json)[0]

$requestBody = @{
    data = @(
        @{
            background = @{
                path = $personUpload
                orig_name = $personName
                mime_type = "image/jpeg"
                meta = @{ _type = "gradio.FileData" }
            }
            layers = @()
            composite = $null
        },
        @{
            path = $garmentUpload
            orig_name = $garmentName
            mime_type = "image/jpeg"
            meta = @{ _type = "gradio.FileData" }
        },
        $Prompt,
        $AutoMask,
        $AutoCrop,
        $Steps,
        $Seed
    )
    event_data = $null
    fn_index = 2
    trigger_id = 25
    session_hash = $session
} | ConvertTo-Json -Depth 10 -Compress

$bodyPath = Join-Path $OutputDir "idm_request_$stamp.json"
Set-Content -Path $bodyPath -Value $requestBody -Encoding ASCII

Write-Host "Submitting try-on job..."
$join = & curl.exe -s -X POST -H "Content-Type: application/json" --data-binary "@$bodyPath" "$spaceRoot/queue/join" | ConvertFrom-Json
Write-Host "Event ID: $($join.event_id)"

Write-Host "Waiting for result..."
$events = & curl.exe -s -N "$spaceRoot/queue/data?session_hash=$session"
$completedLine = $events | Where-Object { $_ -like 'data: {"msg":"process_completed"*' } | Select-Object -Last 1

if (-not $completedLine) {
    Write-Host $events
    throw "No process_completed event was returned."
}

$jsonText = $completedLine -replace '^data:\s*', ''
$completed = $jsonText | ConvertFrom-Json

if (-not $completed.success) {
    Write-Host ($completed | ConvertTo-Json -Depth 8)
    throw "IDM-VTON Space returned an unsuccessful result."
}

$resultUrl = $completed.output.data[0].url
$maskedUrl = $completed.output.data[1].url
$resultPath = Join-Path $OutputDir "tryon_${stamp}.png"
$maskedPath = Join-Path $OutputDir "masked_${stamp}.png"

& curl.exe -L -s $resultUrl -o $resultPath
& curl.exe -L -s $maskedUrl -o $maskedPath

Write-Host "Saved result: $resultPath"
Write-Host "Saved masked: $maskedPath"
