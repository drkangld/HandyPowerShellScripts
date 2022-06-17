#This does a secure login then screen scrape of Jira issues.

#Encryption Setup
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

#Authentication
$user = [CENSORED]
$pat = [CENSORED]
$pair = "$($user):$($pat)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
#The header passes the authenticaion information
$Headers = @{
 Authorization = $basicAuthValue
}

#REST API Call and filtering data.  

#Only for Project 'EDM' 
#Hardcoding project key for EDM because URI is a single quoted string --no variable substitution
#TODO I guess I could do some string manipulation to use variables and build the string....?
#Use Invoke-WebRequest to send the API call with the authentication header and store the results in a variable
#$results=Invoke-WebRequest -Uri 'https://milwaukeetool.atlassian.net/rest/api/3/search?jql=project=EDM' -Headers $Headers


$results=Invoke-WebRequest -Uri 'https://milwaukeetool.atlassian.net/issues/?jql=project%20%3D%20%22EDM%22%20ORDER%20BY%20created%20DESC' -Headers $Headers
#$results=Invoke-WebRequest -Uri 'https://milwaukeetool.atlassian.net/rest/api/3/search?jql=project=EDM&maxResults=100' -Headers $Headers
#$results=Invoke-WebRequest -Uri 'https://milwaukeetool.atlassian.net/rest/api/3/search?jql=project=EDM&maxResults=100' -Headers $Headers


#Find table in the html
$tableHeader = $results.AllElements | Where-Object {$_.tagname -eq 'th'}
$tableData = $results.AllElements | Where-Object {$_.tagname -eq 'td'}

#Table header and data
$thead = $tableHeader.innerText[0..(($tableHeader.innerText.count) - 1)]
$tdata = $tableData.innerText

#Break table data into smaller chuck of data.
$dataResult = New-Object System.Collections.ArrayList
for ($i = 0; $i -le $($tdata.count); $i+= $($($thead.count) - 1))
{
    write-host "i=$i tdata.count=$($tdata.count) thead.count=$($thead.count)"
    if ($($tdata.count) -eq $i)
    {
        break
    }        
    $group = $i + $($($thead.count) - 1)
    [void]$dataResult.Add($tdata[$i..$group])
    $i++
}
#Html data into powershell table format
$finalResult = @()
foreach ($data in $dataResult)
{
    $newObject = New-Object psobject
    #Subtract 2 because the last column is null and we don't need it anyway
    for ($i = 0; $i -le $($($thead.count) - 2); $i++) {
        write-host "i=$i thead.count=$($($thead.count) - 1) i=$i thread-i=$($thead[$i])"
        $newObject | Add-Member -Name $thead[$i] -MemberType NoteProperty -value $data[$i]

    }
    $finalResult += $newObject
}
$finalResult | ft -AutoSize
$finalResult | ConvertTo-csv -NoTypeInformation | out-file -FilePath "pleasework.csv"


