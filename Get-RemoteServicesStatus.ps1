$RDSServerPfx = "BRKRDS"
$MaxSrvs=24
$ServerList = @()

Write-Host "Finding services that are not started but should be" -ForegroundColor Green
Write-Host "Only checking servers that are alive"
Write-host "Server list with no output is good"
for ($Count=1;$Count -le $MaxSrvs;$Count++){
        if(Test-Connection ($RDSServerPfx+$Count) -count 1 -ErrorAction SilentlyContinue){
            #Write-Host "Server exists:$RDSServerPfx$Count"
            #$ServerList +=$RDSServerPfx+$Count
            Write-Host "$RDSServerPfx$Count" -ForegroundColor Yellow
            Get-CimInstance win32_service -filter "startmode = 'auto' and state != 'running' and ExitCode !=0" -ComputerName $($RDSServerPfx+$Count)
            #Get-CimInstance win32_service -filter "startmode = 'auto' and state != 'running' and ExitCode !=0" -ComputerName BRKAXHF10

        } else {Write-Host "$RDSServerPfx+$Count does not ping" -ForegroundColor Red}

    }
        


    






