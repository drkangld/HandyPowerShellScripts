start-transcript
Write-Host "Passing in Target server and database..."
$TargetHost = "<<TargetHost>>"
$TargetTXDatabase = "<<TargetTXDatabase>>"
Write-Host "Setting up backup files..."
$Transdbbkfile = "<<Transdbbkfile>>"
$Modeldbbkfile = "<<Modeldbbkfile>>"
Write-Host "Error checking..."
try
{
  Write-Host "Checking $Transdbbkfile"
  if (-NOT (test-path -Path $Transdbbkfile))
  {
    Throw "Failed to find path: $Transdbbkfile"
  }
  Write-Host "Checking $Modeldbbkfile"
  if (-NOT (Test-Path -Path $Modeldbbkfile))
  {
   Throw "Failed to find path: $Modeldbbkfile"
  }
  Write-Host "Pinging $TargetHost"
  if (-NOT (Test-Connection -BufferSize 32 -Count 1 -ComputerName $TargetHost -Quiet))
  {
    Throw  "Target remote Server not responding: $TargetHost"
  }
  Write-Host "Checking if $TargetTXDatabase exists"
  $sqlquery = "SELECT name FROM master.sys.databases WHERE name LIKE '" +$TargetTXDatabase+ "'"
  $result = Invoke-Sqlcmd -ServerInstance $TargetHost -Database "master" -Query $sqlquery
  if(-NOT ($result.item.IsGettable))
  {
    Throw "Database $TargetTXDatabase does NOT exist!"
  } else
  	{
    	write-host "Target is $TargetHost and Target Database is $TargetTXDatabase"
    	Write-Host "Adding eventlog entry for refresh...."
    	Invoke-command -Computername $TargetHost -ScriptBlock {
  	  	#New-EventLog –LogName Application –Source “DevOps”
		Write-EventLog -LogName Application -Source "DevOps" -EntryType Information -EventID 666 -Message  "$env:username : Refresh from Gold backup via JAMS Scheduled Job"
	}
    start-transcript
    Write-Host -ForegroundColor Green "Starting Refresh of $TargetHost with full backup"
    #Restore-DAXEnvironment -TargetDatabaseInstance $TargetHost -TargetTransactionalDatabase $TargetTXDatabase -TransactionalBackupFile $Transdbbkfile -ModelDatabaseBackupFile $Modeldbbkfile -backupexisting  -Verbose 3>&1 2>&1
  }
}



#Catch Errors
catch 
{
    write-Error $_
}
