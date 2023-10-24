Import-Module JAMS
cls
$jamsServer = ""
$jamsServer = "<ServerName>"
$JAMSReportFile = "<PATH>-$jamsServer.csv"
$JAMSFolders = ""
try
{
    if ($null -eq (Get-PSDrive JD))
    {New-PSDrive JD JAMS $($jamsServer) -scope Local}
}
catch
{New-PSDrive JD JAMS $jamsServer -scope Local}


#Get all the JAMS Scheduler folder definition names that are not in the SAMPLES folder
$JAMSFolders = Get-ChildItem JD:\* -ObjectType folder -IgnorePredefined -FullObject | ?{$_.QualifiedName -ne "\Samples"}

#Get all the jobs within each folder)
$EachJob = @{}
$AllJobs = ''
$JobCount = 0
#Write File Header
Write-Output """JAMSServer"",""JAMSFolderName"",""JAMSTeam"",""JAMSJobName"",""JAMSAgentName"",""ExecutionMethod"",""Enabled"",""LastError"",""LastSuccess""" | Out-File $($JAMSReportFile) -Force
Foreach ($JAMSFolder in $JAMSFolders) {
    #Get all the Jobs in the folder recursively
    $Jobs = ""
    $Jobs = Get-ChildItem -Path JD:\$($JAMSFolder.Name) -Recurse -ObjectType Job -FullObject
         
    #Filter out just the enabled jobs
    Foreach ($Job in $Jobs) {
        #If we wanted to filter just enabled jobs
        #$Job.Properties | select * | Where {$_.PropertyName -eq "Enabled" -AND $_.Value -eq $true}
        $IsEnabled = $job.properties | Select * | Where {$_.PropertyName -eq "Enabled"} | Select Value

        #Extract Team Owner
        $JAMSTeam = $($($Job.QualifiedFolderName).Split("\/"))[1]

        #Write to file
        Write-Output """$jamsServer"",""$($Job.QualifiedFolderName)"",""$JAMSTeam"",""$($Job.Name)"",""$($Job.AgentName)"",""$($Job.MethodName)"",""$($IsEnabled.Value)"",""$($Job.LastError)"",""$($Job.LastSuccess)"""  | Out-File $($JAMSReportFile) -Append
        $JobCount++
     

    }


   

}
Write-Output "JAMS Total Job Count: $JobCount"
Write-Output "Removing PSDrive"
Remove-PSDrive -Name JD




