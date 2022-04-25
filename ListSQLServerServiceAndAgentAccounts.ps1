#Get-WmiObject win32_service -ComputerName BRKAXHF10 | where {$_.name -eq 'MSSQLServer' -or $_.Name -eq 'SQLSERVERAGENT' } 
cls
$ComputerList = ''
$ComputerList = Get-Content C:\Temp\ComputerList.txt
$SQLServiceAccounts = @{}

foreach ($Computer in $ComputerList) {
  $SQLServiceAccounts.add("$Computer-SQLServerService","$($(Get-WmiObject win32_service -ComputerName $Computer | where {$_.name -eq 'MSSQLServer'}).startname)")
  $SQLServiceAccounts.add("$Computer-SQLServerAgentService","$($(Get-WmiObject win32_service -ComputerName $Computer | where {$_.name -eq 'SQLSERVERAGENT'}).startname)")

  Write-host $Computer
  if ($SQLServiceAccounts."$Computer-SQLServerService" -eq $SQLServiceAccounts."$Computer-SQLServerAgentService") 
  {
   Write-host $SQLServiceAccounts."$Computer-SQLServerService" -ForegroundColor Green
   Write-Output $SQLServiceAccounts."$Computer-SQLServerService" | Out-File c:\temp\SQLServiceAccounts.txt -Append
  }
  else
  {
  Write-host "SQL Server and Agent Services are different" 
  Write-host "$SQLServiceAccounts."$Computer-SQLServerService" $SQLServiceAccounts."$Computer-SQLServerAgentService"" -ForegroundColor Red
  write-output $SQLServiceAccounts."$Computer-SQLServerService" | Out-File c:\temp\SQLServiceAccounts.txt -Append
  Write-Output $SQLServiceAccounts."$Computer-SQLServerAgentService" | Out-File c:\temp\SQLServiceAccounts.txt -Append
   }
 
}
