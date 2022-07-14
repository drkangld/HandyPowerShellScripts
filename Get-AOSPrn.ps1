<#
.Synopsis
   Gets list of printer information from a list of AOS servers
.DESCRIPTION
   Gets list of printer information from a list of hard coded AOS servers.
   I am not proud of this but it was quick and dirty.
   Stollen from C. Martinez  7/14/2022
.EXAMPLE
   Just  run this file in PowerShell with an ADMIN account.  Functions are overkill for this application
.INPUTS
   None
.OUTPUTS
   CSV timestamped file in C:\Temp
#>
#Setup server list because I'm too lazy to type for AOS server 1-19
$serverPfx=("ServerPrefix-ChangeForYourEnvironment")
$serverList=@()
for ($n=1; $n -lt 20; $n++){$serverList+="$serverPfx$n"}

$Timestamp=get-date -f yyyyMMdd-hhmmss

foreach ($svr in $serverList)
{
 $res=get-printer -computerName $svr | Select-Object ComputerName,@{N='Printer Name';Expression={$_.Name}},DriverName,Portname | export-csv -Append -Path C:\temp\AOSPrinters_$Timestamp.csv -NoTypeInformation
}
