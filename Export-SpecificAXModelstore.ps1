Start-Transcript
. "C:\Program Files\Microsoft Dynamics AX\60\ManagementUtilities\Microsoft.Dynamics.ManagementUtilities.ps1"
Set-Location c:\export
$date = get-date -Format yyyyMMdd
Export-AXmodelstore -file c:\export\AX_HFX_model-Backup_$date.axmodelstore -Server BRKAXHFX -Database AX_HFX_model -Details -Verbose
