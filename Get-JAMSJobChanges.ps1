CLS
$jobs = ''
Import-Module JAMS
New-PSDrive JD JAMS <ServerInstance> -ErrorAction SilentlyContinue
CD JD:\
$jobs = Get-Childitem -Recurse -objecttype Job -ignorePredefined -FullObject
cd c:\
Remove-PSDrive JD
#Filter for only changes in 2023
$Report = $jobs | Select-Object JobName,MethodName,LastChange,QualifiedFolderName | where {$_.LastChange -like "*2023*"} 
#Replace "MSDAX2012Job" with something more meaningful.
foreach ($r in $Report) { if($r.MethodName -eq "MSDAX2012Job") {$r.MethodName="AX Batch Job"}}
#Convert the object to .CSV and save to file.
$Report | convertto-csv -NoTypeInformation  | out-file c:\temp\JAMS_Job_Changes_2023.csv 
