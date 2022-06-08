$servers = Get-Content C:\temp\ComputerList.txt 
$line = @()
$Table = @()



        $header = @"
        <style>

            h1 {
                font-family: Arial, Helvetica, sans-serif;
                color: #e68a00;
                font-size: 28px;
            } 
            h2 {
                font-family: Arial, Helvetica, sans-serif;
                color: #000099;
                font-size: 16px;
            } 
            table {
		        font-size: 12px;
		        border: 0px; 
		        font-family: Arial, Helvetica, sans-serif;
	        } 
	        td {
		        padding: 4px;
		        margin: 0px;
		        border: 0;
	        }
            th {
                background: #395870;
                background: linear-gradient(#49708f, #293f50);
                color: #fff;
                font-size: 11px;
                text-transform: uppercase;
                padding: 10px 15px;
                vertical-align: middle;
	        }
            tbody tr:nth-child(even) {
                background: #f0f0f2;
            }

            #CreationDate {
                font-family: Arial, Helvetica, sans-serif;
                color: #ff3300;a
                font-size: 12px;
            } 
            #InternalUse {
                font-family: Arial, Helvetica, sans-serif;
                font-weight: bold;
                color: #ff3300;
                font-size: 12px;
                text-align: center;
            }         
            .ONLINE {
                color: #008000;
            }
            .OFFLINE {
                color: #ff0000;
                font-weight: bold;
            }
        </style>
"@


foreach ($server in $servers)
{
        $TXDB = $(Invoke-Sqlcmd -server $server -database "master" -query {SELECT name AS "AX_Transactional_DB" FROM sys.databases WHERE name LIKE '[AX]%' AND name NOT like '%model' AND Name NOT like 'AXDB' AND name Not like '%offline%' AND name NOT like '%trac%' and Name NOT like '%replica%' and Name NOT like 'AXTRA' and name NOT like '%baseline%' and Name NOT like '%IDMF%'  and Name NOT like '%Archive%' and Name NOT like 'AX%_arch' and Name NOT like '%setup%'and Name NOT like 'AX_%ARCH_Master%' and Name NOT like '%AXSYNC%'}).AX_Transactional_DB
        $RefreshDate = $($(Invoke-Sqlcmd -ServerInstance $server -Database $TXDB -query {Select MKETESTTOINTDATETIME FROM MKETESTTOINT}).MKETESTTOINTDATETIME)
        Write-host "$Server Database $TXDB was last refreshed on $RefreshDate"
        $line = New-object -TypeName psobject -Property @{
            Server = "$server"
            AXDB = "$TXDB"
            RefreshDate = "$RefreshDate"
        }
        switch ($server)
        {         
          BRKAXHF1        {$assignedTo = "Fawad Siddiqui"}
          BRKAXHF2        {$assignedTo = "Farooq Karim"}
          BRKAXHF3        {$assignedTo = "Jossuet Farfan"}
          BRKAXHF4        {$assignedTo = "Dave Laymon"}
          BRKAXHF5        {$assignedTo = "Shared"}
          BRKAXHF6        {$assignedTo = "Franklin Arguello"}
          BRKAXHF7        {$assignedTo = "Rich Ramos"}
          BRKAXHF8        {$assignedTo = "Patrik Riberio"}
          BRKAXHF9        {$assignedTo = "Justin Kurtz"}
          BRKAXHF10       {$assignedTo = "Cris Martinez"}
          BRKAXHF12       {$assignedTo = "Vacant"}
          BRKAXDEV5       {$assignedTo = "RFSmart - P.Buckle,Musser,Reynolds"}
          BRKAXDEV8       {$assignedTo = "Vacant"}
          BRKAXDEV11      {$assignedTo = "Vacant"}
          BRKAXDEV12      {$assignedTo = "WorkDay-M.Page"}
          BRKAXDEV13      {$assignedTO = "App Support Team"}
          OBDCAXSQLtrain1 {$assignedTo = "Training Env - J.Caputa"}
          default         {$assignedTo = ""}
        
        }
        $line | Add-Member -NotePropertyName "Assigned_To" -NotePropertyValue $assignedTo


        $Table += $line | Select-Object Server,AXDB,RefreshDate,Assigned_To


}

$Report = $Table | sort {$_.RefreshDate -as [datetime]} | ConvertTo-html -Head $Header  | Out-file 'C:\Temp\AX_REFRESH_REPORT.HTML'
Invoke-Item C:\Temp\AX_REFRESH_REPORT.HTML
