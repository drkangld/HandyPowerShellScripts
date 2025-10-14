# Requires PAT information, Project key
param (
    [Parameter(Mandatory = $true)]
    [string]$JiraBaseUrl,

    [Parameter(Mandatory = $true)]
    [string]$ProjectKey,

    [Parameter(Mandatory = $true)]
    [string]$UserEmail,

    [Parameter(Mandatory = $true)]
    [string]$ApiToken,

    [string]$OutputFile = ".\JiraExport_$((Get-Date).ToString('yyyyMMdd_HHmmss')).json"
)

# --- Auth setup ---
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$UserEmail`:$ApiToken"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Accept"        = "application/json"
    "Content-Type"  = "application/json"
}

Write-Host "Exporting all issues from Jira project $ProjectKey ..." -ForegroundColor Cyan

# --- Step 1: Fetch issues using Enhanced JQL API ---
$nextPageToken = $null
$allIssues = @()
$maxResults = 100

do {
    $body = @{
        jql = "project = $ProjectKey ORDER BY created DESC"
        maxResults = $maxResults
        fields = @("summary", "status", "issuetype", "created", "updated", "description", "comment", "priority", "reporter", "assignee", "labels")
    }

    if ($nextPageToken) {
        $body.Add("nextPageToken", $nextPageToken)
    }

    $jsonBody = $body | ConvertTo-Json -Depth 3
    $url = "$JiraBaseUrl/rest/api/3/search/jql"

    Write-Host "Fetching issues..."

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $jsonBody
        $allIssues += $response.issues
        $nextPageToken = $response.nextPageToken
    }
    catch {
        Write-Host "Error retrieving issues: $($_.Exception.Message)" -ForegroundColor Red
        break
    }

} while ($nextPageToken)

Write-Host "Retrieved $($allIssues.Count) issues from project $ProjectKey." -ForegroundColor Green

# --- Step 2: Save output ---
$allIssues | ConvertTo-Json -Depth 15 | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "Export complete! File saved to $OutputFile" -ForegroundColor Cyan



Write-Host "Converting data and exporting to CSV" -ForegroundColor Cyan

# Flatten and export to CSV
$allIssues | ForEach-Object {
    $fields = $_.fields
    $comments = $fields.comment.comments | ForEach-Object { $_.body }
    $commentText = $comments -join " | "

    [PSCustomObject]@{
        Key         = $_.key
        Summary     = $fields.summary
        Status      = $fields.status.name
        IssueType   = $fields.issuetype.name
        Created     = $fields.created
        Updated     = $fields.updated
        Description = $fields.description
        Comments    = $commentText
        Priority    = $fields.priority.name
        Reporter    = $fields.reporter
        Assignee    = $fields.assignee.displayName
        Labels      = $fields.labels
    }



} | Export-Csv -Path ".\JiraExport_$((Get-Date).ToString('yyyyMMdd_HHmmss')).csv" -NoTypeInformation -Encoding UTF8
