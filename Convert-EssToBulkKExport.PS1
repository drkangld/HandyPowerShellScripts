cls
Write-Host "Stollen from Cris Martinez" -ForegroundColor Red
$jsonObject = Read-Host -Prompt "Enter the AIS string"
cls
try
{
     $jsonObject = ($jsonObject | ConvertFrom-Json) 
}


catch
{
    write-host "Json Input `n###`n$jsonObject`n###" -ForegroundColor white
    throw "  Looks like bad JSON input to me. Try again...`n"
}

Write-Host "  OK There are $($($jsonObject.Parameters).count) Parameters" -ForegroundColor Green

Write-Host "  Renaming OracleJobName to JobName and appending job definition..." -ForegroundColor Green
#Rename OracleJobName to JobName
$jsonObject | Add-Member -MemberType NoteProperty -Name 'JobName' -Value $($jsonObject.OracleJobName+","+$($jsonObject.JobDefinitionName))
$jsonObject.psobject.Properties.remove('OracleJobName')

Write-Host "  Removing unused properties" -ForegroundColor Green
#Remove unused members
$jsonObject.psobject.Properties.remove('InitialJobStatusCheckSeconds')
$jsonObject.psobject.Properties.remove('ExpectedJobRunMinutes')

Write-Host "  Adding prefix 'MessageProperty:' to document parameters, if they exist..." -ForegroundColor Green
foreach ($parm in $jsonObject.Parameters)
{
    $index = $jsonObject.Parameters.IndexOf($parm)
    #Write-Host "Parm is $parm and the index is $index"
    if ($parm -like "*DOCUMENT*")
    {
        #The Document parameters are Case Sensitive so we have to do some fancy string manipulation
        $parm = $parm.ToLower()
        #$parm = $parm.Substring(0,5).ToUpper() + $parm.Substring(1)
        $parm = $parm.Substring(0,5)+$parm.substring(5,1).ToUpper() + $parm.Substring(6,7) + $parm.Substring(13,1).ToUpper() + $parm.Substring(14)
        #$prefixedItem = "$Prefix"+ $parm.Substring(5)
        $prefixedItem = "{{MessageProperty:"+ $parm.Substring(5)
        #Write-Host "New Parm is $prefixedItem and index is $index"
        #Write-Host "$jsonObject.Parameters[$index]"
        $jsonObject.Parameters[$index] = $prefixedItem
    } 
}

#Check for missing parameters
Write-Host "  Adding Missing Defaults..." -ForegroundColor Green
#Add Job options
$jsonObject | Add-Member -MemberType NoteProperty -Name 'JobOptions' -Value 'EnableEvent=N'
#Add CallBack URL
$jsonObject | Add-Member -MemberType NoteProperty -Name 'CallBackURL' -Value '{{CallbackUrl:OracleEssJob}}'
#Add FileName
$jsonObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value "ReplaceMe"
#ADD Notification Code
$jsonObject | Add-Member -MemberType NoteProperty -Name 'NotificationCode' -Value "10"
#Add HasMultipleJobs
$jsonObject | Add-Member -MemberType NoteProperty -Name 'HasMultipleJobs' -Value false
#Add TimeOutMinutes placeholder if not present
if ($jsonObject.TimeOutMinutes -eq $null) {$jsonObject | Add-Member -MemberType NoteProperty -Name 'TimeOutMinutes' -Value 10}

#Convert List to csv string 
Write-Host "  Converting list to parameter string..." -ForegroundColor Green
$jsonObject | ForEach-Object { $_.Parameters = ($($_.Parameters -join ",")); 
    } 
    
    
    
Write-Host "  Output Json text...Note, you might need to join wrapped lines `n" -ForegroundColor Green    
 $jsonObject   | select JobName,JobOptions,CallbackURL,NotificationCode,Parameters,HasMultipleJobs,JobStatusCheckDelaySeconds,TimeoutMinutes| ConvertTo-Json
