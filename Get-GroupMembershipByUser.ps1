CLS
#Import-Module ActiveDirectory
$UserList = Get-Content C:\temp\UserList.txt
foreach ($userName in $UserList)
{
  $UserGroups = ''
  $userName = $userName -replace "met\\",''
  $UserGroups = (Get-ADUser $userName -Properties memberOf).memberof | get-ADGroup | Select-Object name
  #if($user) {Write-host $userName is a member of $groupName}
  #else {Write-Host "$userName is NOT a member of $groupName" -foreground Red}
  foreach ($group in $UserGroups)
  { Write-Host "$userName, $($group.name)"}
}
