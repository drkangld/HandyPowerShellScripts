Import-Module JAMS
Get-JAMSHistory -Server localhost -StartDate 05/20/2023 -EndDate 05/24/2023 | Where {$_.Tags -in "Runaway"} | Select Entry, jobname, Tags
