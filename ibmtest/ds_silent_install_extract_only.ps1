# --- Configuration ---
$BucketName = "dm-mettleci-public"
$ObjectKey  = "binaries/IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$LocalTmp   = "C:\is_temp"
$ZipFile    = Join-Path $LocalTmp "IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ExtractDir = Join-Path $LocalTmp "IS_Client_Extract"
$ResponseFile = "C:\is_temp\client_install_response.txt"

# --- 1. Preparation ---
if (!(Test-Path $LocalTmp)) { New-Item -ItemType Directory -Path $LocalTmp }

# --- 2. Download from IBM COS (S3) ---
Write-Host "Downloading $ObjectKey from $BucketName..." -ForegroundColor Cyan
# Replace with your stored credentials or ensure your environment variables are set
Read-S3Object -BucketName $BucketName -Key $ObjectKey -File $ZipFile -EndpointUrl "https://s3.us.cloud-object-storage.appdomain.cloud"

# --- 3. Extraction ---
Write-Host "Extracting media to $ExtractDir..." -ForegroundColor Cyan
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force