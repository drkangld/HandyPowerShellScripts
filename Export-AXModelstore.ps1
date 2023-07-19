. "C:\Program Files\Microsoft Dynamics AX\60\ManagementUtilities\Microsoft.Dynamics.ManagementUtilities.ps1"
$timeStamp = (Get-Date).ToString("yyyMMdd_HHmmss")
export-axmodelstore -File "C:\export\AX_VAL1_model-backup_$timeStamp.axmodelstore" -database AX_VAl1_model -server SQLAXVAL1 -details -verbose
