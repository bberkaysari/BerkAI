param(
    [string]$SourceRoot = "C:\USB_DressCode_Backup\DressCode",
    [string]$OutputRoot = "C:\USB_DressCode_Backup\DressCode_IDM",
    [string[]]$Categories = @("upper_body"),
    [ValidateSet("HardLink", "Copy")]
    [string]$FileMode = "HardLink",
    [int]$Limit = 0,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

function New-Directory {
    param([string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Copy-Or-LinkFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Missing source file: $Source"
    }

    if ((Test-Path -LiteralPath $Destination) -and -not $Force) {
        return
    }

    if ((Test-Path -LiteralPath $Destination) -and $Force) {
        Remove-Item -LiteralPath $Destination -Force
    }

    if ($FileMode -eq "HardLink") {
        try {
            New-Item -ItemType HardLink -Path $Destination -Target $Source | Out-Null
            return
        }
        catch {
            Write-Warning "HardLink failed, copying instead: $Destination"
        }
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Save-DensePoseJpeg {
    param(
        [string]$SourcePng,
        [string]$DestinationJpg
    )

    if ((Test-Path -LiteralPath $DestinationJpg) -and -not $Force) {
        return
    }

    if ((Test-Path -LiteralPath $DestinationJpg) -and $Force) {
        Remove-Item -LiteralPath $DestinationJpg -Force
    }

    $sourceImage = [System.Drawing.Image]::FromFile($SourcePng)
    try {
        $bitmap = New-Object System.Drawing.Bitmap $sourceImage.Width, $sourceImage.Height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.Clear([System.Drawing.Color]::Black)
                $graphics.DrawImage($sourceImage, 0, 0, $sourceImage.Width, $sourceImage.Height)
            }
            finally {
                $graphics.Dispose()
            }

            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
                Where-Object { $_.MimeType -eq "image/jpeg" } |
                Select-Object -First 1
            $encoder = [System.Drawing.Imaging.Encoder]::Quality
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters 1
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter $encoder, 95L
            $bitmap.Save($DestinationJpg, $jpegCodec, $encoderParams)
        }
        finally {
            if ($bitmap) {
                $bitmap.Dispose()
            }
        }
    }
    finally {
        $sourceImage.Dispose()
    }
}

function Get-CategoryCaption {
    param([string]$Category)

    switch ($Category) {
        "upper_body" { return "upper body garment" }
        "lower_body" { return "lower body garment" }
        "dresses" { return "dress" }
        default { return $Category.Replace("_", " ") }
    }
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Source root not found: $SourceRoot"
}

New-Directory -Path $OutputRoot

foreach ($category in $Categories) {
    $sourceCategory = Join-Path $SourceRoot $category
    $outputCategory = Join-Path $OutputRoot $category

    if (-not (Test-Path -LiteralPath $sourceCategory)) {
        throw "Category not found: $sourceCategory"
    }

    Write-Host ""
    Write-Host "Preparing category: $category"
    Write-Host "Source: $sourceCategory"
    Write-Host "Output: $outputCategory"

    foreach ($folder in @("images", "keypoints", "label_maps", "skeletons", "image-densepose")) {
        New-Directory -Path (Join-Path $outputCategory $folder)
    }

    foreach ($pairFile in @("train_pairs.txt", "test_pairs_paired.txt", "test_pairs_unpaired.txt")) {
        $sourcePair = Join-Path $sourceCategory $pairFile
        $targetPair = Join-Path $outputCategory $pairFile
        if (Test-Path -LiteralPath $sourcePair) {
            Copy-Item -LiteralPath $sourcePair -Destination $targetPair -Force
        }
    }

    foreach ($folder in @("images", "keypoints", "label_maps", "skeletons")) {
        $sourceFolder = Join-Path $sourceCategory $folder
        $targetFolder = Join-Path $outputCategory $folder

        if ($Limit -eq 0 -and $FileMode -eq "Copy") {
            $robocopyArgs = @(
                $sourceFolder,
                $targetFolder,
                "/E",
                "/MT:16",
                "/R:2",
                "/W:1",
                "/NFL",
                "/NDL",
                "/NJH",
                "/NJS",
                "/NP",
                "/XF",
                "._*"
            )
            & robocopy @robocopyArgs | Out-Null
            if ($LASTEXITCODE -gt 7) {
                throw "robocopy failed for $sourceFolder -> $targetFolder with exit code $LASTEXITCODE"
            }

            $count = (Get-ChildItem -LiteralPath $targetFolder -File | Measure-Object).Count
            Write-Host ("  {0}: {1} files (robocopy)" -f $folder, $count)
            continue
        }

        $files = Get-ChildItem -LiteralPath $sourceFolder -File | Where-Object { -not $_.Name.StartsWith("._") }

        if ($Limit -gt 0) {
            $files = $files | Select-Object -First $Limit
        }

        $count = 0
        foreach ($file in $files) {
            Copy-Or-LinkFile -Source $file.FullName -Destination (Join-Path $targetFolder $file.Name)
            $count += 1
        }

        Write-Host ("  {0}: {1} files ({2})" -f $folder, $count, $FileMode)
    }

    $denseSource = Join-Path $sourceCategory "dense"
    $denseTarget = Join-Path $outputCategory "image-densepose"
    $denseFiles = Get-ChildItem -LiteralPath $denseSource -File -Filter "*_5.png" | Where-Object { -not $_.Name.StartsWith("._") }

    if ($Limit -gt 0) {
        $denseFiles = $denseFiles | Select-Object -First $Limit
    }

    $denseCount = 0
    foreach ($file in $denseFiles) {
        $targetName = $file.Name -replace "_5\.png$", "_0.jpg"
        Save-DensePoseJpeg -SourcePng $file.FullName -DestinationJpg (Join-Path $denseTarget $targetName)
        $denseCount += 1

        if (($denseCount % 500) -eq 0) {
            Write-Host "  image-densepose: $denseCount converted..."
        }
    }

    Write-Host "  image-densepose: $denseCount converted to RGB JPEG"

    $caption = Get-CategoryCaption -Category $category
    $captionLines = Get-ChildItem -LiteralPath (Join-Path $sourceCategory "images") -File -Filter "*_1.jpg" |
        Where-Object { -not $_.Name.StartsWith("._") } |
        ForEach-Object { "$($_.Name) $caption" }

    Set-Content -LiteralPath (Join-Path $outputCategory "dc_caption.txt") -Value $captionLines -Encoding ASCII
    Write-Host "  dc_caption.txt: $($captionLines.Count) garment captions"
}

Write-Host ""
Write-Host "Done. IDM DressCode dataset root: $OutputRoot"
