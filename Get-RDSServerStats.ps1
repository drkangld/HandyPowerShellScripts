# Change 'Notepad' to the process name of your liking. Remember to include the single quotes.
$ServerPfx = 'BRKRDS'
$serverSfx = '.met.globaltti.net'
$processname = 'ax32'
$timestamp = Get-Date -format "yyyy/MM/dd-HH:mm"
$Outfile = "C:\Temp\RdsStats.csv"
if (!$(test-path -Path $Outfile)) 
    {
     $Header = "Timestamp,RDSServer,CPUTime,AvailMem,RDSUsersDisconnected,TotalRDSSessions,ProcessName,ProcessCount"
     $Header | Out-File -FilePath $Outfile
    } 

#Find Number of user sessions per RD Server
$RDUsers = $(Get-RDUserSession -ConnectionBroker BRKRDSBROKER1.met.globaltti.net -CollectionName 'BRKRDSFARM').hostserver | sort | group | % { $h = @{} } { $h[$_.Name] = $_.Count } { $h }
#Find Number of DISCONNECTED user sessions per RD Server
$RDUsersDisc = Get-RDUserSession -ConnectionBroker BRKRDSBROKER1.met.globaltti.net -CollectionName 'BRKRDSFARM' | select-object ServerName, Sessionstate | Where-Object SessionState -eq "STATE_DISCONNECTED" | group -Property ServerName | % { $h = @{} } { $h[$_.Name] = $_.Count } { $h }
#Count number of $processname per server
for ($count =1;$count -lt 25;$count++)
  {
    $rdsServer = $ServerPfx+$count
    $process = Get-Process $processname -ComputerName $rdsServer -ErrorAction silentlycontinue
    if ($process) 
      {
       $processCount = @($process).count
      } else
         {
           $processCount = '0'
         }
       
       if ($RDUsers.$($rdsServer+$serverSfx))
         {
          $ServerUsers = $RDUsers.$($rdsServer+$serverSfx)
          $ServerUsersDisconnected = $RDUsersDisc.($rdsServer+$ServerSfx)
         } else { $ServerUsers = 0
                  $ServerUsersDisconnected = '0'
                }

       #Memory and CPU Stats
       $cpuTime = (Get-Counter -ComputerName $rdsServer '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
       $availMem = (Get-Counter -ComputerName $rdsServer '\Memory\Available MBytes').CounterSamples.CookedValue

       #Check Total Process or time
       #$rdsserverCPU = (Get-Counter -ComputerName $rdsServer '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
       #$rdsServerMemory = (Get-Counter -ComputerName $rdsServer '\Memory\Available MBytes').CounterSamples.CookedValue  
       #$msg = "$rdsServer $ServerUsersDisconnected of $ServerUsers sessions are disconnected, $processCount active processes of $processname"
       $msg = $rdsServer +' CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%) ' + $ServerUsersDisconnected + ' of ' + $ServerUsers + ' sessions are disconnected ' + $processCount + ' active processes of ' + $processname
       Write-Host "$msg"
      
       # $Header = "Timestamp,RDSServer,CPUTime,AvailMem,TotalMem,RDSUsersDisconnected,TotalRDSSessions,ProcessName,ProcessCount"
       $log = $timestamp + ',' + $rdsServer + ',' + $($cpuTime.ToString("#,0.000") + '%') + ',' + '"'+ $($availMem.ToString("N0") + 'MB') + '"' + ',' + $ServerUsersDisconnected + ',' + $ServerUsers + ',' + $processname + ',' + $processCount
       

       $log | Out-File -FilePath $Outfile -Append
 
 }





