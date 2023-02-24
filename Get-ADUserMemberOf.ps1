Function Get-ADUserMemberOf
{
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$User,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Group
  )
  try{
    $GroupDN = (Get-ADGroup $Group).DistinguishedName
    $UserDN = (Get-ADUser $User).DistinguishedName
    $Getaduser = Get-ADUser -Filter "memberOf -RecursiveMatch '$GroupDN'" -SearchBase $UserDN
    If($Getaduser) {
      $true
    }
    Else { 
      $false 
    }
  }
  catch{

  }
} #Get-ADUserMemberOf
