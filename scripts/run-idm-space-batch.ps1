param(
    [string]$DatasetRoot = "C:\USB_DressCode_Backup\DressCode\upper_body",
    [string]$PairsFile = "test_pairs_unpaired.txt",
    [string]$OutputDir = "C:\USB_DressCode_Backup\DressCode\_idm_results\batch",
    [int]$Count = 5,
    [int]$Start = 0,
    [int]$Seed = 42,
    [string]$Prompt = "upper body garment"
)

$ErrorActionPreference = "Stop"

$singleScript = Join-Path $PSScriptRoot "run-idm-space-tryon.ps1"
if (-not (Test-Path -LiteralPath $singleScript)) {
    throw "Single try-on script not found: $singleScript"
}

$pairsPath = Join-Path $DatasetRoot $PairsFile
if (-not (Test-Path -LiteralPath $pairsPath)) {
    throw "Pairs file not found: $pairsPath"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$pairs = Get-Content -LiteralPath $pairsPath |
    Where-Object { $_.Trim().Length -gt 0 } |
    Select-Object -Skip $Start -First $Count

$index = $Start
foreach ($line in $pairs) {
    $parts = $line -split "\s+"
    if ($parts.Count -lt 2) {
        Write-Warning "Skipping malformed pair: $line"
        continue
    }

    $personName = $parts[0]
    $garmentName = $parts[1]
    $personImage = Join-Path $DatasetRoot "images\$personName"
    $garmentImage = Join-Path $DatasetRoot "images\$garmentName"
    $pairOutput = Join-Path $OutputDir ("{0:D3}_{1}_{2}" -f $index, ($personName -replace "\.jpg$", ""), ($garmentName -replace "\.jpg$", ""))

    New-Item -ItemType Directory -Force -Path $pairOutput | Out-Null
    Copy-Item -LiteralPath $personImage -Destination (Join-Path $pairOutput "person.jpg") -Force
    Copy-Item -LiteralPath $garmentImage -Destination (Join-Path $pairOutput "garment.jpg") -Force

    Write-Host "[$index] $personName + $garmentName"
    & powershell -ExecutionPolicy Bypass -File $singleScript `
        -PersonImage $personImage `
        -GarmentImage $garmentImage `
        -Prompt $Prompt `
        -OutputDir $pairOutput `
        -Seed ($Seed + $index)

    if ($LASTEXITCODE -ne 0) {
        throw "Try-on failed for pair ${personName} + ${garmentName}. Stopping batch."
    }

    $index += 1
}
