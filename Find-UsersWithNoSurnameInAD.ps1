#$User = Read-Host -Prompt 'Input the user name'; Get-ADUser -Filter {name -like $User -or samaccountname -like $User} | select SamAccountName, Enabled

$usernames = Import-Csv "C:\Temp\DAXDevUsers.txt" -Header Surname,GivenName -Delimiter "," 
ForEach ($Name in $userNames)
{
    $FirstFilter = $Name.Givenname
    $SecondFilter = $Name.Surname
    if($($name.SurName) -gt 0) { 
    #Write-Host "$FirstFilter, $($FirstFilter.Length) -  $SecondFilter, $($SecondFilter.Length)"

    } Else {Write-Host "$name has no Surname" -ForegroundColor RED}

    #Get-ADUser -Filter { GivenName -like $FirstFilter -and Surname -like $SecondFilter} |select enabled,samaccountname,@{n="ou";e={($_.distinguishedname -split ",*..=")[2]}} 
} 

