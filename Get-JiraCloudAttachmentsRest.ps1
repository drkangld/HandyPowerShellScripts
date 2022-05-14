#Stollen from C. Martinez 5/13/2022
#I am NOT proud of this
#It is down and dirty but got the job done.
#The ask was to download all the attachments in Jira Cloud for a specific project.
#I decided the best way to structure it is by Jira ticket ID.
#Don't forget to make an access token and write down the password.
#Encryption Setup
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

#Authentication
$user = '[email@domain.com]'
$pat = '[CENSORED]'
$pair = "$($user):$($pat)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
 Authorization = $basicAuthValue
}

#REST API Call and filtering data.  
#Only for Project 'NOW' and only tickets with attachments
#Project key is hardcoded for now because URI is a single quoted string --no variables
#Also, Max Ticket count is 100 set by Jira :(
$results=Invoke-WebRequest -Uri 'https://milwaukeetool.atlassian.net/rest/api/3/search?jql=project=NOW  AND Attachments IS NOT Empty&fields=attachment&maxResults=100' -Headers $Headers

#Split the results property into lines of data
$attachmentIssues = $results.content -split "," | select-string -pattern  key,content,filename | select-string -pattern author,AccountID -NotMatch

#Set Parent File Path
$exportPath = "F:\JiraExport"

foreach ($line in $attachmentIssues)
{
  switch ($line.pattern)
  {
    key {
          #Test path for directory named KEY, if not there make it, set path to that subfolder
          $ticket = $($($line -split ":")[1]).replace('"','') 
          $ticketPath = Join-Path -path $exportPath -ChildPath $ticket         
          Write-Host "Jira Ticket is $ticket"
          if([System.IO.Directory]::Exists($ticketPath))
          {
            Write-Host "Directory Exists!  YaY"
          }
          else
          {
            Write-Host "Folder $ticketPath does not exist.  Making new folder"
            New-item $ticketPath -ItemType Directory
          }
        }
    filename {
              $fileName = $($line -split ":")[1].Replace('"','')
              Write-Host "The file name is $fileName"
              #Test if the file already exists, otherwise set filename variable to this (scrubbed content string)
             }
    content {
             $link = $line -REPLACE ('"content":','') -REPLACE ('}','') -REPLACE (']','') -REPLACE ('"','')
             Write-host "The download link is $link"
             
             $downloadPath = $(Join-Path $ticketPath -ChildPath $fileName)          
             Write-Host "Output file will be $downloadPath"
             Invoke-WebRequest -uri $link -headers $headers -outfile $downloadPath
            }
   }



}


