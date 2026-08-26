Start-Transcript -Path "C:\is_temp\beacon_transcript.log" -Append

# --- Configuration Parameters ---
$DsUser     = "isadmin"
$DsPassword = "9BaAMKZjzmTiDcJtRb"
$Server     = "10.10.10.201"
$FlagUrl    = "http://${Server}:58080/project_ready.txt"
$IsxPath    = "C:\is_temp\jenkins_devops.isx"
$IstoolDir  = "C:\IBM\InformationServer\Clients\istools\cli"
# --------------------------------

try {
    # 1. Check if the RHEL server has stood up the flag
    $response = Invoke-WebRequest -Uri $FlagUrl -UseBasicParsing -TimeoutSec 5
    
    if ($response.StatusCode -eq 200) {
        
        # 2. Silently accept the new WebSphere SSL Certificate into the trust store (IBM Native Method)
        $AsbNodeDir = "C:\IBM\InformationServer\ASBNode\bin"
        Set-Location $AsbNodeDir
        .\UpdateSignerCerts.bat -url "https://${Server}:59445" -user $DsUser -password $DsPassword -silent
        
        # 3. Cert trusted! Navigate to the istool directory and run the import cleanly
        Set-Location $IstoolDir
        .\istool.bat import -domain "${Server}:59445" -username $DsUser -password $DsPassword -archive $IsxPath -datastage "server-1/Jenkins_Devops" -replace -silent > C:\is_temp\istool_background.log 2>&1
        
        # 4. If the import succeeds, kill the scheduled task so it never runs again
        if ($LASTEXITCODE -eq 0) {
            Unregister-ScheduledTask -TaskName "DataStageISXImport" -Confirm:$false
        }
    }
} catch {
    # Flag file not found or network down. Exit silently and wait for the next interval.
}

Stop-Transcript
