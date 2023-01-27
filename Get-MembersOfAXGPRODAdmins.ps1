cls
#Set the outfile path
$outFile = "C:\Temp\outfile.csv"
#Clear the content of the file for each run
if (Test-path -Path $outFile) {Clear-Content -Path $outFile}

$bob = Get-ADGroupMember -Identity "AXGPRODAdmin" | Select-Object name,objectClass

#$bob

foreach ($line in $bob){
 #write-host "$($line.Name), $($line.objectClass)"
 $name = $($line.name)
 $objClass = $($line.objectClass)

 #If the account is a user account, we're good
 if ($objClass -eq 'user'){
 write-host "$name, $objClass" -ForegroundColor green 
 echo "$name,$objClass" | Add-Content -path $outFile
  
 }

 #If the account is a group, get the members of it.  I'm only going 1 level deeper here since we dont' have multiple levels.
 if ($objClass -eq 'group'){
 write-host "$name, $objClass" -ForegroundColor red
 echo "$name,$objClass" | Add-Content -path $outFile

 $sub = Get-ADGroupMember -identity $name | Select-Object name,objectClass
 #$sub
 foreach ($line2 in $sub){
  $name2 = $($line2.name)
  $objClass2 = $($line2.objectClass)
  write-host " - $name2, $objClass2" -ForegroundColor Yellow
  echo " - ,$name2,$objClass2" | Add-Content -path $outFile
  }
 }
}



