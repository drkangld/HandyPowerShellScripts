<# What I'm looking for:
  File Name
  File Date Created?
  IDs processed as an array
#>

#File Name
$logPath = "UNC File Path"
#Get all the file names I'm looking for
$logFiles = Get-ChildItem -path $logPath | where {$_.BaseName -like "SALES - Import eService Repairs (new)*"}
#Gets the create date for each log file, ingests the file, looks for the line that contains the orders

foreach ($logFile in $logFiles)
{ 
  $fileDate = $(Get-ChildItem -Path $logPath\$logFile).CreationTime
  $log = Get-Content -Path $logPath\$logFile
  #Splits the orders line into an array after scrubbing the prefix 'IDs processed;' 
  foreach ($line in $log)
  { 
    if($line -like "*IDs processed*") {
    $serviceOrders = $line
    $serviceOrders = $($serviceOrders.replace('    IDs processed: ','')).split(",")
    #Write-Host "File: \'$fileName \' dated $fileDate has $($serviceOrders.count) orders"

    #Output the file name, file create date, and the count of orders
    Write-output "$fileName,$fileDate,$($serviceOrders.count)" | Out-file -FilePath c:\temp\eServiceOrders.csv -Append
    }
  }
}
