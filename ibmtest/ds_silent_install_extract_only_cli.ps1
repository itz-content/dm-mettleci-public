# ==============================================================================
# TechZone Windows postDeploy Script: Install AWS CLI & Stream S3 Binaries
# ==============================================================================

# 1. Setup variables (TechZone injections match lowercase names from JSON)
$RemoteStagingPath   = $env:remote_staging_path   # e.g., "D:\IBM\InformationServer"
$S3BucketName        = $env:s3_bucket_name        # e.g., "dm-mettleci-public"
$AwsEndpointUrl      = $env:aws_endpoint_url      # e.g., "https://s3..."
$MainTar             = "IS_V11716_Linux_x86_multi.tar.gz"
$SpecZip             = "IS_V11716.bundle_spec_file_mult.zip"

# Inject AWS Credentials into the current session process environment
$env:AWS_ACCESS_KEY_ID     = $env:aws_access_key_id
$env:AWS_SECRET_ACCESS_KEY = $env:aws_secret_access_key

# 2. Ensure Staging Directory Exists
if (-not (Test-Path -Path $RemoteStagingPath)) {
    New-Item -ItemType Directory -Force -Path $RemoteStagingPath | Out-Null
    Write-Output "Created staging directory: $RemoteStagingPath"
}

# 3. Download and Install AWS CLI v2 Silently (if not already present)
$AwsCliPath = "C:\Program Files\Amazon\AWSCLIV2\aws.exe"
if (-not (Test-Path -Path $AwsCliPath)) {
    Write-Output "AWS CLI not found. Starting installation..."
    $MsiPath = "$env:TEMP\AWSCLIV2.msi"
    
    # Download official installer
    Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile $MsiPath
    
    # Run completely silent installation and wait for it to finish
    Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`" /qn /norestart" -Wait
    Remove-Item $MsiPath -Force
    Write-Output "AWS CLI installation completed successfully."
}

# 4. CRITICAL: Force active PowerShell session to discover the new 'aws' command
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 5. Download the Main Tarball using AWS CLI
Write-Output "Starting download of Main Tarball from S3..."
aws s3 cp `
  "s3://$S3BucketName/$MainTar" `
  "$RemoteStagingPath\$MainTar" `
  --endpoint-url $AwsEndpointUrl

# 6. Download the Bundle Spec Zip
Write-Output "Starting download of Bundle Spec Zip..."
aws s3 cp `
  "s3://$S3BucketName/$SpecZip" `
  "$RemoteStagingPath\$SpecZip" `
  --endpoint-url $AwsEndpointUrl

# 7. Extract Archives natively in Windows
Write-Output "Extracting binaries..."
Expand-Archive -Path "$RemoteStagingPath\$SpecZip" -DestinationPath "$RemoteStagingPath\is-suite" -Force

# Note: Windows doesn't natively extract .tar.gz out-of-the-box with Expand-Archive.
# Since AWS CLI includes a lightweight version of tar, we use that to unzip the main bundle:
tar -f "$RemoteStagingPath\$MainTar" -C $RemoteStagingPath -xz

# 8. Cleanup downloaded zip/tar files to save disk space
Remove-Item "$RemoteStagingPath\$MainTar" -Force
Remove-Item "$RemoteStagingPath\$SpecZip" -Force

Write-Output "postDeploy script execution completed successfully!"