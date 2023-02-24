#Set File Path
$file = "C:\TEMP\TFSUserDump.csv"
#TFS Groups
$tfsGroups = ("AXGSUBBatchUsers","AXGSUBDev","AXGSUBDEVOneKey","AXGSUBFirefighter","AXGSUBITSupport","AXGSUBServiceAcct","Dynamics AX Developers","Dynamics AX Devs","Dynamics AX Users","EnvistaDevs","IT_SERVICES_APPLICATION_DEVELOPMENT","MCA Connect","ServerAdmins","SonataAXDev","TFS2Admin")
#$tfsGroups = ("Dynamics AX Developers") #test with 1 group
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
} 


#IF File Exists
#Read the first line of the file and assign to $s
if(Test-Path $file) {
    $tfsusers = Import-Csv $file
    #Add 'Enabled' Property
    $tfsusers | Add-Member -MemberType NoteProperty -Name Enabled -Value ''
    #Dynamically add the groups as member properties
    foreach ($g in $tfsGroups) {
        $tfsusers | Add-Member -MemberType NoteProperty -Name $g -Value ''
    }

    #Keep track of the index for the array to reference each row so we're using a for loop  
    for($i=0;$i -le $($tfsusers.length -1);$i++) {
        if ($tfsusers[$i].sid.Length -gt 0) {
            #Get-ADUser doesn't like the object parameter so I have to assign the account item to a variable first.
            $accountName = $tfsusers[$i].AccountName
            $ADEnabled = Get-ADUser -Filter { name -like $accountName -or samaccountname -like $accountName } | select Enabled
            if($ADEnabled) {
                              $tfsusers[$i].Enabled = $ADEnabled.Enabled
                           } else {
                                        $tfsusers[$i].Enabled = "Service_Account_OR_Object_Not_Found"
                                  }
        #If the email address can't be retrieved put a dummy address in
        if ($tfsusers[$i].MailAddress) {} else {$tfsusers[$i].MailAddress = "not_found@milwaukeetool.com"}

        foreach ($g in $tfsGroups) {
            $isGrpMember = Get-ADUserMemberOf -User $tfsusers[$i].AccountName -Group $g
            if ($null -ne $isGrpMember) {
                $tfsusers[$i].$g = $isGrpMember
            } else {$tfsusers[$i].$g = "NA"}
           

        }
       










        
        }


    }



}
