
#Test-NetConnection -Computername <computername> -Port < ##  >


cls
$servers = Get-Content C:\temp\ComputerList.txt 
foreach ($server in $servers)
{
    IF(Test-Connection -ComputerName $server -Count 1 -Quiet) 
        {write-host "$Server is" -NoNewline
         Write-host " up" -ForegroundColor Green

         } Else {
                     Write-host "$Server is" -NoNewline
                     Write-Host " DOWN" -ForegroundColor Red
                }
  }
