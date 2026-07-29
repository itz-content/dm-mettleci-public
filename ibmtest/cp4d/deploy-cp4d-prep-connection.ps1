# 1 & 2. Rename the key
Rename-Item -Path "$env:USERPROFILE\Downloads\vm_ssh_key.vm" -NewName "cp4d_ssh_key.vm" -ErrorAction SilentlyContinue

$KeyPath = "$env:USERPROFILE\Downloads\cp4d_ssh_key.vm"

# 3. Lock down permissions
icacls $KeyPath /c /t /inheritance:d
icacls $KeyPath /c /t /remove "Administrator" "BUILTIN\Administrators" "Everyone" "Authenticated Users"
icacls $KeyPath /c /t /grant "${env:USERNAME}:F"

# 3.5. Prompt for the full string and split it to get the endpoint
$FullString = Read-Host -Prompt "Paste the full Bastion SSH Connection string"
$Endpoint = ($FullString -split ' ')[1]
[Environment]::SetEnvironmentVariable("ITZ_API_ENDPOINT", $Endpoint, "Process")

Write-Host "Endpoint parsed as: $Endpoint" -ForegroundColor Cyan

# 4. Create remote .kube directory and copy the config file
Write-Host "Transferring kubeconfig to bastion..."
ssh -p 10022 -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i $KeyPath $Endpoint "mkdir -p ~/.kube"
scp -P 10022 -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i $KeyPath "$env:USERPROFILE\Downloads\conf_kubeconfig_download.conf" "${Endpoint}:~/.kube/config"

Write-Host "✅ Local prep and transfer complete." -ForegroundColor Green