Import-Module JAMS
New-PSDrive JD JAMS <JAMSSERVERNAME> -ErrorAction SilentlyContinue
CD JD:\
$jobs = Get-Childitem -Recurse -objecttype Job -ignorePredefined -FullObject
$OldEmail = "Partial@email.com"
#$OldEmail = "Martinez@milwaukeetool.com"
#$NewEmail = "New_Email"
ForEach($job in $jobs){

    $elements = $job.elements
    ForEach($element in $elements){

        If($element.ElementTypeName -eq "SendEMail" -and $element.ToAddress -like "*$OldEmail*"){
           Write-Host "Found email: $OldEmail, in Job $($job.QualifiedName)."
           #$element.ToAddress = $element.ToAddress.Replace($OldEmail,$NewEmail)
           #$job.Update() 
        }
    }
}
