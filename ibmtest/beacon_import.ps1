Start-Transcript -Path "C:\is_temp\beacon_transcript.log" -Append

# Adjust these variables to match your environment's naming conventions
$Server = "10.10.10.201"
$FlagUrl = "http://${Server}:58080/project_ready.txt"
$DsUser = "isadmin"
$DsPassword = "9BaAMKZjzmTiDcJtRb"
$IsxPath = "C:\is_temp\jenkins_devops.isx"
$AsbNodeDir = "C:\IBM\InformationServer\ASBNode\bin"
$IstoolDir = "C:\IBM\InformationServer\Clients\istools\cli"

try {
    # 1. Check if the RHEL server has stood up the flag
    $response = Invoke-WebRequest -Uri $FlagUrl -UseBasicParsing -TimeoutSec 5
    
    if ($response.StatusCode -eq 200) {
        Write-Host "Beacon detected! Commencing DataStage import."
        
        # 2. Silently accept the new WebSphere SSL Certificate into the local trust store
        Set-Location $AsbNodeDir
        .\UpdateSignerCerts.bat -url "https://${Server}:59445" -user $DsUser -password $DsPassword -silent
        
        # 3. Cert trusted! Navigate to the istool directory and run the import cleanly.
        # NOTE: No '-silent' flag here, so the background log captures the actual output!
        Set-Location $IstoolDir
        .\istool.bat import -domain "${Server}:59445" -username $DsUser -password $DsPassword -archive $IsxPath -datastage "server-1/Jenkins_Devops" -replace > C:\is_temp\istool_background.log 2>&1
        
        # 4. If the import succeeds, kill the scheduled task so it never runs again
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Import successful. Terminating Scheduled Task."
            Unregister-ScheduledTask -TaskName "DataStageISXImport" -Confirm:$false
        } else {
            Write-Host "Import failed with Exit Code: $LASTEXITCODE"
        }
    }
} catch {
    # Flag file not found or network down. Exit silently and wait for the next interval.
    Write-Host "Waiting for RHEL beacon..."
}

Stop-Transcript
