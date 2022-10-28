
cls
$servers = Get-Content C:\temp\ComputerListCleaned.txt 
$line = @()
$Table = @()

foreach ($server in $servers)
{
        $TXDB = $(Invoke-Sqlcmd -server $server -database "master" -query {SELECT name AS "AX_Transactional_DB" FROM sys.databases WHERE name LIKE '[AX]%' AND name NOT like '%model' AND Name NOT like 'AXDB' AND name Not like '%offline%' AND name NOT like '%trac%' and Name NOT like '%replica%' and Name NOT like 'AXTRA' and name NOT like '%baseline%' and Name NOT like '%IDMF%'  and Name NOT like '%Archive%' and Name NOT like 'AX%_arch' and Name NOT like '%setup%'and Name NOT like 'AX_%ARCH_Master%' and Name NOT like '%AXSYNC%'}).AX_Transactional_DB
        $AXTier = $($(Invoke-Sqlcmd -ServerInstance $server -Database $TXDB -query {SELECT ENVMODE from MCAENVIRONMENTMAP}).envmode)
        
        $line = New-object -TypeName psobject -Property @{
            Server = "$server"
            AXDB = "$TXDB"
            RefreshDate = "$RefreshDate"
        }
        switch ($AXTier)
        {   
          0               {$AXTier = "Development"}
          1               {$AXTier = "Test"}
          2               {$AXTier = "Production"}              
        }
        Write-host "$Server Environment Tier of $AXTier"
        $line | Add-Member -NotePropertyName "AXEnvironmentTier" -NotePropertyValue $AXTier


        $Table += $line | Select-Object Server,AXDB,AXTier


}

