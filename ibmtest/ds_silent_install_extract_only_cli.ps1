# ==============================================================================
# Techzone postDeploy Script: Pull IBM Client via AWS CLI
# ==============================================================================

# --- Configuration ---
$LocalTmp          = "C:\is_temp"
$ObjectKey         = "binaries/IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ZipFile           = "C:\is_temp\IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ExtractDir        = "C:\is_temp\IS_Client_Extract"

# NEW: Natively parse the TechZone variables file from disk to bypass scoping bugs
$JsonPath = "C:\Temp\post_deploy_repo\post_deploy_variables.json"
if (Test-Path $JsonPath) {
    Write-Host "Found TechZone variables file. Parsing parameters..." -ForegroundColor Green
    $Variables = Get-Content -Raw $JsonPath | ConvertFrom-Json
    
    # Inject directly into the child process environment for the AWS CLI binary
    $env:AWS_ACCESS_KEY_ID     = $Variables.AWS_ACCESS_KEY_ID
    $env:AWS_SECRET_ACCESS_KEY = $Variables.AWS_SECRET_ACCESS_KEY
    $env:AWS_BUCKET_NAME       = $Variables.AWS_BUCKET_NAME
    $env:AWS_ENDPOINT_URL      = $Variables.AWS_ENDPOINT_URL
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

# 2b. WinSCP Installation (Using Filename Variable)
$WinScpPath = "C:\Program Files (x86)\WinSCP\WinSCP.exe"
if (-not (Test-Path -Path $WinScpPath)) {
    Write-Host "WinSCP not found. Fetching installer from private S3 bucket..." -ForegroundColor Cyan
    
    # Define the installer filename in a single variable for easy updates
    $WinScpFileName = "WinSCP-6.5.6-Setup.exe"
    
    # Construct the absolute path string using the variable
    $LocalInstallerPath = "C:\Users\itzuser\Downloads\$WinScpFileName"
    
    # Execute the pull directly using the variable paths
    aws s3 cp "s3://$env:AWS_BUCKET_NAME/binaries/$WinScpFileName" $LocalInstallerPath --endpoint-url $env:AWS_ENDPOINT_URL

    # Simple verification check on the literal file path
    if (Test-Path $LocalInstallerPath) {
        $FileSizeMB = [math]::Round((Get-Item $LocalInstallerPath).Length / 1MB, 2)
        Write-Host "WinSCP Installer verified in Downloads ($FileSizeMB MB). Running installation..." -ForegroundColor Cyan
        
        # Hardcoded single-string argument block to prevent parsing issues
        $OuterArguments = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCLOSEAPPLICATIONS /ALLUSERS'
        
        # Launch the install process natively from the variable path
        $Process = Start-Process -FilePath $LocalInstallerPath -ArgumentList $OuterArguments -Wait -NoNewWindow -PassThru
        
        Write-Host "Installer process exited with Code: $($Process.ExitCode)" -ForegroundColor Yellow
        
        # Final validation check to ensure binaries are in Program Files
        if (Test-Path -Path $WinScpPath) {
            Write-Host "SUCCESS: WinSCP installation verified at target path!" -ForegroundColor Green
        } else {
            Write-Error "CRITICAL: The installer ran, but the binaries are missing from $WinScpPath."
        }
    } else {
        Write-Error "CRITICAL: Download failed. The file is missing from $LocalInstallerPath"
    }
    
    # Clean up the installer from Downloads after execution
    if (Test-Path $LocalInstallerPath) { 
        Remove-Item $LocalInstallerPath -Force 
    }
} else {
    Write-Host "WinSCP is already present. Skipping task." -ForegroundColor Green
}
# Force the running session to reload the path to find the 'aws' executable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

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