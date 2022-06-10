$servers = Get-Content C:\temp\ComputerList.txt
foreach ($server in $servers)
{
  $TXDB = $(Invoke-Sqlcmd -server $server -database "master" -query {SELECT name AS "AX_Transactional_DB" FROM sys.databases WHERE name LIKE '[AX]%' AND name NOT like '%model' AND Name NOT like 'AXDB' AND name Not like '%offline%' AND name NOT like '%trac%' and Name NOT like '%replica%' and Name NOT like 'AXTRA' and name NOT like '%baseline%' and Name NOT like '%IDMF%'  and Name NOT like '%Archive%' and Name NOT like 'AX%_arch' and Name NOT like '%setup%'and Name NOT like 'AX_%ARCH_Master%' and Name NOT like '%AXSYNC%'}).AX_Transactional_DB
  $rowCount = $($(Invoke-Sqlcmd -ServerInstance $server -Database $TXDB -query {select count(JURISDICTIONID) from MKEJURISDICTIONTABLE where JURISDICTIONID = 41}).Column1)
  if($rowCount -eq 0){
  write-host "Updated the table on $server"
  $sqlQ = invoke-sqlcmd -server $server -database $TXDB -query {INSERT INTO MKEJURISDICTIONTABLE VALUES('CAN',41,'QST/PST','met',1,5637144576,5637146076)}
  }
  else {
  write-host "Row already exists on $server"
  }

}
