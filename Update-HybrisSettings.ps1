cls
Start-Transcript
$servers = Get-Content C:\temp\ComputerListLowerEnvSQL.txt
$sqlCMD = "C:\temp\HybrisSQL.sql"

foreach ($server in $servers)
{
 Write-Host "Getting Transactional Database for $server"
 $TXDB = $(Invoke-Sqlcmd -server $server -database "master" -query {SELECT name AS "AX_Transactional_DB" FROM sys.databases WHERE name LIKE '[AX]%' AND name NOT like '%model' AND Name NOT like 'AXDB' AND name Not like '%offline%' AND name NOT like '%trac%' and Name NOT like '%replica%' and Name NOT like 'AXTRA' and name NOT like '%baseline%' and Name NOT like '%IDMF%'  and Name NOT like '%Archive%' and Name NOT like 'AX%_arch' and Name NOT like '%setup%'and Name NOT like 'AX_%ARCH_Master%' and Name NOT like '%AXSYNC%'}).AX_Transactional_DB
  Write-Host "Transactional DB: $TXDB"
  #Write-Host "Crossing fingers and running SQL update..."
  Invoke-Sqlcmd -InputFile $sqlCMD -server $server -Database $TXDB 
  Write-Host "Update done for $server" 
}


