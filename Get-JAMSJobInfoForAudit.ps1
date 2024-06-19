<#
.SYNOPSIS
This script pulls job information from a given JAMS Scheduler server.

.DESCRIPTION
This script will 
    1. Query a given JAMS Scheduler server and retrieve all the user
    2. Create a unique sorted list of JAMS Folders
    3. Iterate through each folder and extract specific job information
    4. Export the data to a .csv file for further analysys

.PARAMETER 
None.  JAMS Scheduler server name and output file are configured
in the header.

.EXAMPLE


#Requires -JAMS module
#>


Import-Module JAMS
cls

$jamsServer = "BRKJAMSQC3"
$JAMSReportFile = "C:\temp\Outfile-$($jamsServer)_$(Get-date -f yyyyMMdd-hhmmss).csv"
$JAMSFolder = "\"

#Check if JAMS drive exists, if not create it.
If (!(Test-Path JD:))
{ New-PSDrive -Name JD JAMS $jamsServer } else {}

#Get  list of unique folders and subfolders in JAMS
$UniqueJAMSFolders = Get-childItem JD:\* -ObjectType folder -IgnorePredefined -Recurse | Select-Object QualifiedName -Unique

#Export the header row to file
$fileHeader = @("Team", "FolderQN", "JobName", "JobDescription", "JobAgent", "JobType", "LastChangedBy", "LastAutoSubmit", "IsEnabled")
$fileHeader -join ',' | Out-File -FilePath $JAMSReportFile


#Find all the jobs in the folder, skip zArchive folders and JAMS folder
Foreach ($folder in $UniqueJAMSFolders) {
  if ($($folder.QualifiedName) -match "zArchive|JAMS") {
    Write-Host "Skipping Folder:$($folder.QualifiedName)" -ForegroundColor Cyan
  }
  else {
    $jobTeam = $($($folder -split "\\")[1]).ToString()
    Write-Host "Team: $jobTeam - Folder: $($Folder.QualifiedName)" -ForegroundColor Green

    #Get the jobs in the folder (array of jobs)
    [PSCustomObject]$JobInfo = Get-ChildItem JD:\$($folder.QualifiedName)\* -ObjectType job -IgnorePredefined

    #Iterate through each job
    Foreach ($job in $($JobInfo)) {
              
      $IsEnabled = $($job.Properties | Where-Object { $_.PropertyName -eq 'Enabled' }).value
      Write-host "  - Job: $($job.Name) Enabled?: $IsEnabled"
              
      #Data Clean up
      #Problems with Job Description field - Remove special characters and non-print whitespaces, etc.
      $cleanString = $job.Description -replace '"', '' -replace '[^\x20-\x7E]', '' -replace ',', '' -replace '^\s*$', '' -replace "(\r\n)+", "`r`n"
      $job.Description = $cleanString

      #Since the job description is free form, we need to account for varying lengths
      #If there's no description, put a 'No Description' descriptor
      #Set a cap on the column width (currently 60 characters)
      #If it's more, truncate. If less, take the whole thing.
      $checkLength = $($job.Description).Length
      if ($checkLength -eq 0) { 
        $jobDescription = "No Description" 
      }
      else {
        if ($checkLength -gt 60) {
          $jobDescription = $job.Description.Substring(0, 60)
        }
        else { $jobDescription = $($job.Description) }
      }
                     

      #Data Row array - This is the format I want in the csv
      #If you change this, also change the header line to line things up.
      $outItems = @()
      $outItems += $jobTeam, $($Folder.QualifiedName), $($job.Name), $jobDescription, $($job.AgentName), $($job.MethodName), $($job.LastChangedBy), $($job.LastAutosubmit), $($IsEnabled)
      #An array gives me a list. Use -join to go horizontally for the columns without having to create another object.
      #If I was keeping the data as part of a larger structure, I'd change to a different method.
      #But, I'm not, so, yay!
      $outItems -join "," | Out-File -FilePath $JAMSReportFile -Append
    }
  }
} 

#Clean up.
Write-Host "Cleaning up... removing JAMS Drive"
Remove-PSDrive JD
