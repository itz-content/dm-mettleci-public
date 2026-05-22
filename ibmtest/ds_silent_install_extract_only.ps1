# --- Configuration ---
$BucketName = "dm-mettleci-public"
$ObjectKey  = "binaries/IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$LocalTmp   = "C:\is_temp"
$ZipFile    = Join-Path $LocalTmp "IS_V11.7.1.6_WINDOWS_CLIENT.zip"
$ExtractDir = Join-Path $LocalTmp "IS_Client_Extract"
$ResponseFile = "C:\is_temp\client_install_response.txt"
$EndPointUrl = "https://s3.us.cloud-object-storage.appdomain.cloud"

# --- 1. Preparation ---
if (!(Test-Path $LocalTmp)) { New-Item -ItemType Directory -Path $LocalTmp }

# --- 1b. Install AWS Tools for S3 Module ---
Write-Host "Checking for AWS S3 PowerShell module..." -ForegroundColor Cyan

#Bypass execution policy for this specific process execution
Set-ExecutionPolicy Bypass -Scope Process -Force -Confirm:$false

# Force TLS 1.2 to ensure the download from PSGallery doesn't fail on a fresh VM
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Silently download and place the NuGet DLL directly to bypass the prompt
if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Write-Host "Manually bootstrapped NuGet provider bypassing interactive prompts..." -ForegroundColor Yellow
    
    # Define the exact path where PowerShell searches for PackageManagement providers
    $ProviderPath = Join-Path $env:ProgramFiles "PackageManagement\ProviderAssemblies\nuget\2.8.5.208"
    if (!(Test-Path $ProviderPath)) { 
        New-Item -ItemType Directory -Path $ProviderPath -Force | Out-Null 
    }
    
    # Download the DLL directly using basic web request
    $DllUrl = "https://cdn.oneget.org/providers/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll"
    $DllPath = Join-Path $ProviderPath "Microsoft.PackageManagement.NuGetProvider.dll"
    
    Invoke-WebRequest -Uri $DllUrl -OutFile $DllPath -UseBasicParsing
}

#Set PSGallery to trusted so it doesn't prompt "Are you sure you want to install from an untrusted repository?"
if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

if (!(Get-Module -ListAvailable -Name AWS.Tools.S3)) {
    Write-Host "Installing AWS.Tools.Common and AWS.Tools.S3..." -ForegroundColor Yellow
    # -Force and -AllowClobber bypass any prompts so the script runs hands-free
    Install-Module -Name AWS.Tools.Common -Force -AllowClobber -Scope AllUsers
    Install-Module -Name AWS.Tools.S3 -Force -AllowClobber -Scope AllUsers
}

# --- 2. Download from IBM COS (S3) ---
Write-Host "Downloading $ObjectKey from $BucketName..." -ForegroundColor Cyan
# Replace with your stored credentials or ensure your environment variables are set
Read-S3Object -BucketName $BucketName -Key $ObjectKey -File $ZipFile -EndpointUrl $EndPointUrl

# --- 3. Extraction ---
Write-Host "Extracting media to $ExtractDir..." -ForegroundColor Cyan
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force