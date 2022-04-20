cls
$ComputerList = ''
$ComputerList = Get-Content C:\Temp\ComputerList.txt
$SQLServiceAccounts = @{}

foreach ($Computer in $ComputerList) {
  # I want separate hash pairs for SQL Server Service and Agent accounts because they can differ.
  $SQLServiceAccounts.add("$Computer-SQLServerService","$($(Get-WmiObject win32_service -ComputerName $Computer | where {$_.name -eq 'MSSQLServer'}).startname)")
  $SQLServiceAccounts.add("$Computer-SQLServerAgentService","$($(Get-WmiObject win32_service -ComputerName $Computer | where {$_.name -eq 'SQLSERVERAGENT'}).startname)")

  Write-host $Computer
  if ($SQLServiceAccounts."$Computer-SQLServerService" -eq $SQLServiceAccounts."$Computer-SQLServerAgentService") 
  {
   Write-host $SQLServiceAccounts."$Computer-SQLServerService" -ForegroundColor Green
  }
  else
  {
  Write-host "SQL Server and Agent Services are different" 
  Write-host "$SQLServiceAccounts."$Computer-SQLServerService" $SQLServiceAccounts."$Computer-SQLServerAgentService"" -ForegroundColor Red
    }
  
}
