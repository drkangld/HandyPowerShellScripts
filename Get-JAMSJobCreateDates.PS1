Install-Model JAMS
$JAMSServer = 'ServerName'

$bob = Get-JamsAudit -Server $JAMSServer | Where-Object -Property Message -Like 'Add*' | Where-Object -Property ObjectType -EQ 'Job'| Select-Object -Property AuditTime,LoadedFrom,ObjectType,UserName,Message |sort -Property AuditTime -Descending | Export-Csv -Path C:\Temp\"$JAMSServer"_JobCreations.csv
