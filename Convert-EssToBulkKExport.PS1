cls
Write-Host "Stollen from Cris Martinez" -ForegroundColor Red
$jsonObject = Read-Host -Prompt "Enter the AIS string"
cls
$jsonObject = ($jsonObject | ConvertFrom-Json)
Write-Host "OK There are $($($jsonObject.Parameters).count) Parameters" 

Write-Host "Renaming OracleJobName to JobName and appending job definition..."
#Rename OracleJobName to JobName
$jsonObject | Add-Member -MemberType NoteProperty -Name 'JobName' -Value $($jsonObject.OracleJobName+"/"+$($jsonObject.JobDefinitionName))
$jsonObject.psobject.Properties.remove('OracleJobName')

Write-Host "Removing unused properties"
#Remove unused members
$jsonObject.psobject.Properties.remove('InitialJobStatusCheckSeconds')
$jsonObject.psobject.Properties.remove('ExpectedJobRunMinutes')

#Check for missing parameters
Write-Host "Adding Missing Defaults..."
#Add Job options
$jsonObject | Add-Member -MemberType NoteProperty -Name 'JobOptions' -Value 'EnableEvent=N'
#Add CallBack URL
$jsonObject | Add-Member -MemberType NoteProperty -Name 'CallbackURL' -Value '{{CallbackUrl:OracleEssJob}}'
#Add FileName
$jsonObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value "ReplaceMe"
#ADD Notification Code
$jsonObject | Add-Member -MemberType NoteProperty -Name 'NotificationCode' -Value "10"
#Add HasMultipleJobs
$jsonObject | Add-Member -MemberType NoteProperty -Name 'HasMultipleJobs' -Value false
#Add TimeOutMinutes placeholder if not present
if ($jsonObject.TimeOutMinutes -eq $null)
    {
      $jsonObject | Add-Member -MemberType NoteProperty -Name 'TimeOutMinutes' -Value "int32"
    }


#Convert List to csv string and export json
Write-Host "Converting list to parameter string..."
Write-Host "Output Json text...Note, you might need to join wrapped lines `n"
$jsonObject | ForEach-Object { $_.Parameters = ($($_.Parameters -join ",")); $_ 
    } | select JobName,JobOptions,CallbackURL,NotificationCode,Parameters,TimeoutMinutes,HasMultipleJobs,JobStatusCheckDelaySeconds| ConvertTo-Json
