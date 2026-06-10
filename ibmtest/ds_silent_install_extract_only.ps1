# --- Configuration ---
$BucketName    = "dm-mettleci-public"
$ObjectKey     = "binaries/IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$LocalTmp      = "C:\is_temp"
$ZipFile       = Join-Path $LocalTmp "IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ExtractDir    = Join-Path $LocalTmp "IS_Client_Extract"
$ResponseFile  = "C:\is_temp\client_install_response.txt"
$EndPointUrl   = "https://s3.us.cloud-object-storage.appdomain.cloud"

# --- External Tooling Endpoints ---
$WinscpUrl     = "https://winscp.net/download/WinSCP-6.5.6-Setup.exe"

# --- 1. Preparation ---
if (!(Test-Path $LocalTmp)) { New-Item -ItemType Directory -Path $LocalTmp }

# --- 1b. Install AWS Tools for S3 Module ---
Write-Host "Checking for AWS S3 PowerShell module..." -ForegroundColor Cyan

# Force PowerShell to refresh its module paths and explicitly import the S3 tools
$env:PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PSModulePath", "User")
Import-Module -Name AWS.Tools.S3 -ErrorAction SilentlyContinue

# --- 1c. Automated WinSCP Installation (Server-Safe Standalone) ---
Write-Host "Checking for WinSCP installation..." -ForegroundColor Cyan

# Check if WinSCP execution alias or file path is already present
$WinscpCheck = Get-Command winscp.exe -ErrorAction SilentlyContinue

if (-not $WinscpCheck) {
    Write-Host "WinSCP not found. Preparing independent network installation from configuration URL..." -ForegroundColor Yellow
    
    $WinscpInstaller = Join-Path $LocalTmp "WinSCP_Setup.exe"
    
    # Download the standalone installer natively using the top-level configuration URL
    Write-Host "Downloading standalone WinSCP installer package..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $WinscpUrl -OutFile $WinscpInstaller -UseBasicParsing
    
    # Execute a completely silent, headless install background task
    Write-Host "Running silent installer execution thread..." -ForegroundColor Cyan
    Start-Process -FilePath $WinscpInstaller -ArgumentList "/allusers", "/silent", "/norestart" -Wait -NoNewWindow
    
    # Quick post-install cleanup of the installer artifact
    if (Test-Path $WinscpInstaller) { Remove-Item $WinscpInstaller -Force }
    Write-Host "WinSCP installation phase complete!" -ForegroundColor Green
} else {
    Write-Host "WinSCP is already installed. Skipping task." -ForegroundColor Green
}

# --- 2. Download from IBM COS (S3) ---
Write-Host "Downloading $ObjectKey from $BucketName..." -ForegroundColor Cyan
# Replace with your stored credentials or ensure your environment variables are set
Read-S3Object -BucketName $BucketName -Key $ObjectKey -File $ZipFile -EndpointUrl $EndPointUrl

# --- 3. Extraction ---
Write-Host "Extracting media to $ExtractDir..." -ForegroundColor Cyan
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force