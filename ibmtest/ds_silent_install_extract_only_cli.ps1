# ==============================================================================
# Techzone postDeploy Script: Pull IBM Client via AWS CLI
# ==============================================================================

# --- Configuration ---
# Hardcoded local paths for predictability on Windows
$LocalTmp          = "C:\is_temp"
$ObjectKey         = "binaries/IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ZipFile           = "C:\is_temp\IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ExtractDir        = "C:\is_temp\IS_Client_Extract"
$ResponseFile      = "C:\is_temp\client_install_response.txt"

# --- 1. Preparation ---
if (!(Test-Path $LocalTmp)) { 
    New-Item -ItemType Directory -Path $LocalTmp | Out-Null 
    Write-Host "Created staging directory at $LocalTmp" -ForegroundColor Green
}

# --- 2. Install AWS CLI v2 Silently ---
$AwsCliPath = "C:\Program Files\Amazon\AWSCLIV2\aws.exe"
if (-not (Test-Path -Path $AwsCliPath)) {
    Write-Host "AWS CLI not found. Installing silently..." -ForegroundColor Cyan
    $MsiPath = "$env:TEMP\AWSCLIV2.msi"
    
    Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile $MsiPath
    Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`" /qn /norestart" -Wait
    Remove-Item $MsiPath -Force
    Write-Host "AWS CLI installation complete." -ForegroundColor Green
}

# Force the running session to reload the path to find the 'aws' executable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# --- 3. Download from IBM COS (S3) via AWS CLI ---
Write-Host "Downloading $ObjectKey from S3 bucket $env:AWS_BUCKET_NAME..." -ForegroundColor Cyan

# AWS CLI natively inherits $env:aws_access_key_id and $env:aws_secret_access_key from Techzone
aws s3 cp `
  "s3://$env:AWS_BUCKET_NAME/$ObjectKey" `
  "$ZipFile" `
  --endpoint-url $env:AWS_ENDPOINT_URL

if (!(Test-Path $ZipFile)) {
    Write-Error "Failed to download $ObjectKey from S3 bucket."
    exit 1
}

# --- 4. Extraction ---
Write-Host "Extracting media to $ExtractDir..." -ForegroundColor Cyan
if (Test-Path $ExtractDir) { 
    Remove-Item $ExtractDir -Recurse -Force 
}
Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force

Write-Host "Download and Extraction completed successfully in $LocalTmp!" -ForegroundColor Green