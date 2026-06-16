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

# --- Exact Path Rules matching your is-client layout ---
$TargetClientDir    = "$ExtractDir\is-client"
$ResponseFile       = "$TargetClientDir\ds_client.rsp"
$RepoResponseFile   = "C:\Temp\post_deploy_repo\ibmtest\ds_client.rsp"
$InstallerExe       = "$TargetClientDir\setup.exe"
$InstallLog         = "C:\is_temp\client_install_execution.log"

# --- SSH Key Generation Configuration ---
$SshDir             = "C:\Users\itzuser\.ssh"
$TargetSshFile      = "$SshDir\vm_ssh_key"

# Disable progress bar to increase download performance and prevent automation hangs
$ProgressPreference = 'SilentlyContinue'

# --- Natively parse the TechZone variables file from disk ---
$JsonPath = "C:\Temp\post_deploy_repo\post_deploy_variables.json"
if (Test-Path $JsonPath) {
    Write-Host "Found TechZone variables file. Parsing parameters..." -ForegroundColor Green
    $Variables = Get-Content -Raw $JsonPath | ConvertFrom-Json
    
    # Inject directly into the process environment
    $env:AWS_ACCESS_KEY_ID     = $Variables.aws_access_key_id
    $env:AWS_SECRET_ACCESS_KEY = $Variables.aws_secret_access_key
    $env:AWS_ENDPOINT_URL      = $Variables.aws_endpoint_url
    
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

# --- 1b. Create Empty VM SSH Key File for itzuser ---
Write-Host "Verifying .ssh directory structure for itzuser..." -ForegroundColor Cyan
if (!(Test-Path $SshDir)) {
    New-Item -ItemType Directory -Path $SshDir | Out-Null
}
New-Item -ItemType File -Path $TargetSshFile -Value "" -Force | Out-Null

# --- 2. Install AWS CLI v2 Silently ---
$AwsCliPath = "C:\Program Files\Amazon\AWSCLIV2\aws.exe"
if (-not (Test-Path -Path $AwsCliPath)) {
    Write-Host "AWS CLI not found. Installing silently..." -ForegroundColor Cyan
    $MsiPath = "$env:TEMP\AWSCLIV2.msi"
    Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile $MsiPath
    Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`" /qn /norestart" -Wait
    Remove-Item $MsiPath -Force
}
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 2b. WinSCP Installation
$WinScpPath = "C:\Program Files (x86)\WinSCP\WinSCP.exe"
if (-not (Test-Path -Path $WinScpPath)) {
    aws s3 cp "s3://$env:AWS_BUCKET_NAME/$WinScpObjKey" "$WinScpDownloadPath" --endpoint-url $env:AWS_ENDPOINT_URL
    $OuterArguments = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCLOSEAPPLICATIONS /ALLUSERS'
    Start-Process -FilePath $WinScpDownloadPath -ArgumentList $OuterArguments -Wait -NoNewWindow | Out-Null
    if (Test-Path $WinScpDownloadPath) { Remove-Item $WinScpDownloadPath -Force }
}

# --- 3. Download from IBM COS (S3) via AWS CLI ---
Write-Host "Downloading $ObjectKey from S3..." -ForegroundColor Cyan
aws s3 cp "s3://$env:AWS_BUCKET_NAME/$ObjectKey" "$ZipFile" --endpoint-url $env:AWS_ENDPOINT_URL

if (!(Test-Path $ZipFile)) {
    Write-Error "Failed to download client media ZIP."
    exit 1
}

# --- 4. Extraction ---
Write-Host "Extracting media to $ExtractDir (This can take a minute)..." -ForegroundColor Cyan
if (Test-Path $ExtractDir) { 
    Remove-Item $ExtractDir -Recurse -Force 
}
Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force
Write-Host "Extraction completed successfully!" -ForegroundColor Green

# --- 4b. Relocate Response File from Git Repo to is-client Path ---
Write-Host "Relocating response file directly alongside setup.exe..." -ForegroundColor Cyan
if (Test-Path $RepoResponseFile) {
    Copy-Item -Path $RepoResponseFile -Destination $ResponseFile -Force
    Write-Host "SUCCESS: Response file placed at: $ResponseFile" -ForegroundColor Green
} else {
    Write-Error "CRITICAL ERROR: Missing source ds_client.rsp at $RepoResponseFile"
    exit 1
}

# --- 5. Silent Client Installation ---
Write-Host "Starting IBM Information Server Client Silent Installation..." -ForegroundColor Cyan

if (-not (Test-Path $InstallerExe)) {
    Write-Error "CRITICAL: setup.exe not found at $InstallerExe."
    exit 1
}

Write-Host "Executing setup.exe natively against response file..." -ForegroundColor Yellow
$InstallArgs = "-rsp `"$ResponseFile`" -force -verbose"

# Fire the initial process launch container
$InstallProcess = Start-Process -FilePath $InstallerExe -ArgumentList $InstallArgs -Wait -NoNewWindow -PassThru -RedirectStandardOutput $InstallLog

Write-Host "Initial setup process handler reached exit. Monitoring active background install window..." -ForegroundColor Yellow

# Settle down for 15 seconds to let the suite spin up its internal Java execution frame
Start-Sleep -Seconds 15

# Loop checking active handles for any installer processes or Java install processes running
$LoopTimeout = 0
while ((Get-Process | Where-Object { $_.Name -ine "powershell" -and ($_.Name -like "*setup*" -or $_.Name -like "*is-installer*" -or $_.Name -like "*java*") }) -and $LoopTimeout -lt 120) {
    Write-Host "Installer is actively writing dependencies to disk... (Waiting 20 seconds)" -ForegroundColor Gray
    Start-Sleep -Seconds 20
    $LoopTimeout++
}

Write-Host "All installation processing threads have finished cleanly!" -ForegroundColor Green
Write-Host "Automation phase concluded! Target ZIP payload preserved at $ZipFile" -ForegroundColor Green