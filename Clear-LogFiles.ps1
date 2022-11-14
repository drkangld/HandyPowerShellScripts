$Path = "C:\TEMP\junk"
$Daysback = "-30"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)

#Object containing all the log files we want to delete
$logfiles = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete }

#if the custom eventlog source does not exist, create it.
if(!($([System.Diagnostics.EventLog]::SourceExists('DevOps'))))
  { 
    Write-Host "Adding eventlog source 'DevOps'" -ForegroundColor Red
    New-EventLog –LogName Application –Source “DevOps”
  } ELSE {Write-Host "DevOps Source already exists" -ForegroundColor green}

$msg = $($logFiles.Fullname) -join "`n" #separate lines for the string
Write-EventLog -LogName "Application" -Source "DevOps" -EventID 1313 -EntryType Information -Message "$($logfiles.count) files deleted from $path on $CurrentDate `n $msg"
Write-Host "Deleting old files..."
Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
Write-host "$($logFiles.count) Files Deleted"



