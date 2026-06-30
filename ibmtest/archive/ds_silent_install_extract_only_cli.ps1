# ==============================================================================
# Techzone postDeploy Script: Pull IBM Client via AWS CLI
# ==============================================================================

# --- Configuration ---
$LocalTmp           = "C:\is_temp"
$ObjectKey          = "binaries/IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ZipFile            = "C:\is_temp\IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ExtractDir         = "C:\is_temp\IS_Client_Extract"
$WinScpObjKey       = "binaries/WinSCP-6.5.6-Setup.exe"
$WinScpDownloadPath = "C:\is_temp\WinSCP-6.5.6-Setup.exe"

# Disable progress bar to increase download performance and prevent automation hangs
$ProgressPreference = 'SilentlyContinue'

# --- Natively parse the TechZone variables file from disk ---
$JsonPath = "C:\Temp\post_deploy_repo\post_deploy_variables.json"
if (Test-Path $JsonPath) {
    Write-Host "Found TechZone variables file. Parsing parameters..." -ForegroundColor Green
    $Variables = Get-Content -Raw $JsonPath | ConvertFrom-Json
    
    # Inject directly into the process environment (Protected against potential JSON casing variations)
    $env:AWS_ACCESS_KEY_ID     = $Variables.aws_access_key_id
    $env:AWS_SECRET_ACCESS_KEY = $Variables.aws_secret_access_key
    $env:AWS_ENDPOINT_URL      = $Variables.aws_endpoint_url
    
    # Gracefully maps whether key is named s3_bucket_name or aws_bucket_name
    if ($Variables.s3_bucket_name) { $env:AWS_BUCKET_NAME = $Variables.s3_bucket_name }
    else { $env:AWS_BUCKET_NAME = $Variables.aws_bucket_name }
} else {
    Write-Error "Critical Error: TechZone variables file not found at $JsonPath"
    exit 1
}

# --- 1. Preparation ---
if (!(Test-Path $LocalTmp)) { 
    New-Item -ItemType Directory -Path $LocalTmp | Out-Null 
}

# --- 2. Install AWS CLI v2 Silently ---
$AwsCliPath = "C:\Program Files\Amazon\AWSCLIV2\aws.exe"
if (-not (Test-Path -Path $AwsCliPath)) {
    Write-Host "AWS CLI not found. Installing silently..." -ForegroundColor Cyan
    $MsiPath = "$env:TEMP\AWSCLIV2.msi"
    Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile $MsiPath
    Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`" /qn /norestart" -Wait
    Remove-Item $MsiPath -Force
}

# Force the running session to reload the path to find the 'aws' executable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 2b. WinSCP Installation
$WinScpPath = "C:\Program Files (x86)\WinSCP\WinSCP.exe"
if (-not (Test-Path -Path $WinScpPath)) {
    Write-Host "WinSCP not found. Fetching installer from private S3 bucket..." -ForegroundColor Cyan
     
    # Execute the pull directly using verified, stable variable paths
    aws s3 cp "s3://$env:AWS_BUCKET_NAME/$WinScpObjKey" "$WinScpDownloadPath" --endpoint-url $env:AWS_ENDPOINT_URL

    # Strict verification block using matched paths
    if (Test-Path $WinScpDownloadPath) {
        $FileSizeMB = [math]::Round((Get-Item $WinScpDownloadPath).Length / 1MB, 2)
        Write-Host "WinSCP Installer verified in temp space ($FileSizeMB MB). Running installation..." -ForegroundColor Cyan
        
        # Hardcoded single-string argument block to prevent parsing issues
        $OuterArguments = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCLOSEAPPLICATIONS /ALLUSERS'
        
        # Launch the install process natively from the variable path
        $Process = Start-Process -FilePath $WinScpDownloadPath -ArgumentList $OuterArguments -Wait -NoNewWindow -PassThru
        
        Write-Host "Installer process exited with Code: $($Process.ExitCode)" -ForegroundColor Yellow
        
        # Final validation check to ensure binaries are in Program Files
        if (Test-Path -Path $WinScpPath) {
            Write-Host "SUCCESS: WinSCP installation verified at target path!" -ForegroundColor Green
        } else {
            Write-Error "CRITICAL: The installer ran, but the binaries are missing from $WinScpPath."
        }
    } else {
        Write-Error "CRITICAL: Download failed. The file is missing: $WinScpDownloadPath"
    }
    
    # Clean up the installer after execution
    if (Test-Path $WinScpDownloadPath) { 
        Remove-Item $WinScpDownloadPath -Force 
    }
} else {
    Write-Host "WinSCP is already present. Skipping task." -ForegroundColor Green
}

# --- 3. Download from IBM COS (S3) via AWS CLI ---
Write-Host "Downloading $ObjectKey from S3 bucket $env:AWS_BUCKET_NAME..." -ForegroundColor Cyan

# Use the flattened single-line execution using the variables loaded out of the JSON file
aws s3 cp "s3://$env:AWS_BUCKET_NAME/$ObjectKey" "$ZipFile" --endpoint-url $env:AWS_ENDPOINT_URL

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

Write-Host "Download and Extraction completed successfully!" -ForegroundColor Green