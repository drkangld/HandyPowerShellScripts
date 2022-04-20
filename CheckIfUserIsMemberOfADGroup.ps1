$groupName = "AxProjectHold-RW"
#Import-Module ActiveDirectory
$UserList = Get-Content C:\temp\SQLServiceAccounts.txt
foreach ($userName in $UserList)
{
  $userName = $userName -replace "met\\",''
  $user = Get-ADGroupMember -Identity $groupName | where-Object {$_.name -eq $userName}
  if($user) {Write-host $userName is a member of $groupName}
  else {Write-Host "$userName is NOT a member of $groupName" -foreground Red}
}
