#Test if credentials are correct. Should return JSON for my account.

$jiraBaseUrl = "https://yourdomain.net"
$projectKey = "JiraProjectHere"
$email = "someone@somwhere.com"
$user = 'PAT_USERIF'
$pat = "PATKey"      # PAT from Jira


$testUrl = "$jiraBaseUrl/rest/api/3/myself"
$response = Invoke-RestMethod -Uri $testUrl -Headers $headers -Method Get
$response
