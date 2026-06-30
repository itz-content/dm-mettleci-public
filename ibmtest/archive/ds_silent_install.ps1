# --- Configuration ---
$BucketName = "dm-mettleci-public"
$ObjectKey  = "binaries/IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$LocalTmp   = "C:\is_temp"
$ZipFile    = Join-Path $LocalTmp "IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ExtractDir = Join-Path $LocalTmp "IS_Client_Extract"
$ResponseFile = "C:\is_temp\client_install_response.txt"

# --- 1. Preparation ---
if (!(Test-Path $LocalTmp)) { New-Item -ItemType Directory -Path $LocalTmp }

# --- 1b. Install AWS Tools for S3 Module ---
Write-Host "Checking for AWS S3 PowerShell module..." -ForegroundColor Cyan

# Force TLS 1.2 to ensure the download from PSGallery doesn't fail on a fresh VM
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (!(Get-Module -ListAvailable -Name AWS.Tools.S3)) {
    Write-Host "Installing AWS.Tools.Common and AWS.Tools.S3..." -ForegroundColor Yellow
    # -Force and -AllowClobber bypass any prompts so the script runs hands-free
    Install-Module -Name AWS.Tools.Common -Force -AllowClobber -Scope AllUsers
    Install-Module -Name AWS.Tools.S3 -Force -AllowClobber -Scope AllUsers
}

# --- 2. Download from IBM COS (S3) ---
Write-Host "Downloading $ObjectKey from $BucketName..." -ForegroundColor Cyan
# Replace with your stored credentials or ensure your environment variables are set
Read-S3Object -BucketName $BucketName -Key $ObjectKey -File $ZipFile -EndpointUrl "https://s3.us.cloud-object-storage.appdomain.cloud"

# --- 3. Extraction ---
Write-Host "Extracting media to $ExtractDir..." -ForegroundColor Cyan
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force

# --- 4. Launch Recorder ---
# Find the setup.exe (usually in the root or 'is-client' folder of the extract)
$SetupPath = Get-ChildItem -Path $ExtractDir -Filter "setup.exe" -Recurse | Select-Object -First 1 -ExpandProperty FullName

if ($SetupPath) {
    Write-Host "Launching DataStage Installer in Record Mode..." -ForegroundColor Green
    Write-Host "Response file will be saved to: $ResponseFile" -ForegroundColor Yellow
    
    # Run setup and wait for completion
    Start-Process -FilePath $SetupPath -ArgumentList "-record `"$ResponseFile`"" -Wait
} else {
    Write-Error "Could not find setup.exe in the extracted files."
}