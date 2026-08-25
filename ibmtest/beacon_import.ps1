# --- Configuration Parameters ---
$DsUser     = "isadmin"
$DsPassword = "9BaAMKZjzmTiDcJtRb"
$Server     = "10.10.10.201"
$FlagUrl    = "http://$Server:58080/project_ready.txt"
$IsxPath    = "C:\Users\itzuser\Downloads\jenkins_devops.isx"
$IstoolDir  = "C:\IBM\InformationServer\Clients\istools\cli"
# --------------------------------

try {
    # If RHEL hasn't created the file yet, this will fail and jump straight to the 'catch' block
    $response = Invoke-WebRequest -Uri $FlagUrl -UseBasicParsing -TimeoutSec 5
    
    if ($response.StatusCode -eq 200) {
        # The file exists! Ansible is completely done. Run the import.
        Set-Location $IstoolDir
        
        "1" | .\istool.bat import -domain "$Server:59445" -username $DsUser -password $DsPassword -archive $IsxPath -datastage "server-1/Jenkins_Devops" -replace -silent
        
        # If the import succeeds, delete this scheduled task so it stops running
        if ($LASTEXITCODE -eq 0) {
            Unregister-ScheduledTask -TaskName "DataStageISXImport" -Confirm:$false
        }
    }
} catch {
    # Flag file not found. Script exits silently and tries again at the next 15-minute interval.
}