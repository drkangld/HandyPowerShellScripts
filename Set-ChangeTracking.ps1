CLS
#Parameters
$DatabaseInstance = "BRKAXHF10" 
$Database = "AX_HF10"

#Get-ChangeTracking Tables

#Export Tables to outfile for logging purposes
$objects = @()
$EnabledChangeTrackingTable = Get-ChangeTrackingTable -TargetDatabaseInstance $DatabaseInstance -TargetTransactionalDatabase $Database
$EnabledChangeTrackingtable | foreach-object{
     $objects +=   [pscustomobject]@{
          Database = $_.Database
          Schema   = $_.Schema
          Table    = $_.table
          tracking = $_.is_track_columns_updated_on
          serverInstrance = $_.serverinstance
          }
}
$objects | Export-Csv -path "C:\temp\ChangeTrackingTables.csv" -NoTypeInformation

#Disable Change tracing
Write-Host "Disable Change tracking..."
$EnabledChangeTrackingTable | Disable-ChangeTrackingTable

Write-host "Checking CT settings on $DatabaseInstance"
if(Get-ChangeTrackingTable -TargetDatabaseInstance $DatabaseInstance -TargetTransactionalDatabase $Database ){Write-Host "This is BAD"} else {Write-Host "Change Tracking is disabled" -ForegroundColor Green}

#Perform dbsync
<#
  #TBD
#>

Write-Host "Pausing to do something..."
pause

#Reneable ChangeTracking
Write-Host "Enabling Change Tracking on $DatabaseInstance"
$EnabledChangeTrackingTable | Enable-ChangeTrackingTable
Get-ChangeTrackingTable -TargetDatabaseInstance $DatabaseInstance -TargetTransactionalDatabase $Database | ft
#Verify CT TBD
