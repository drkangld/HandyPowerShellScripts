# Requires PAT information, Project key
# Uses 2025 API
param (
    [Parameter(Mandatory = $true)]
    [string]$JiraBaseUrl,

    [Parameter(Mandatory = $true)]
    [string]$ProjectKey,

    [Parameter(Mandatory = $true)]
    [string]$UserEmail,

    [Parameter(Mandatory = $true)]
    [string]$ApiToken,

    [Parameter(Mandatory = $true)]
    [string]$ExportPath
)

# --- Auth setup ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$UserEmail`:$ApiToken"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Accept"        = "application/json"
    "Content-Type"  = "application/json"
}

Write-Host "Fetching issues with attachments from project $ProjectKey ..." -ForegroundColor Cyan

# --- JQL to find issues with attachments ---
$jql = "project = $ProjectKey AND attachments IS NOT EMPTY ORDER BY created DESC"
$maxResults = 100
$nextPageToken = $null
$allIssues = @()

do {
    $body = @{
        jql = $jql
        maxResults = $maxResults
        fields = @("summary", "attachment")
    }

    if ($nextPageToken) {
        $body.Add("nextPageToken", $nextPageToken)
    }

    $jsonBody = $body | ConvertTo-Json -Depth 3
    $url = "$JiraBaseUrl/rest/api/3/search/jql"

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

Write-Host "Retrieved $($allIssues.Count) issues with attachments." -ForegroundColor Green

# --- Download attachments ---
foreach ($issue in $allIssues) {
    $key = $issue.key
    $attachments = $issue.fields.attachment

    if ($attachments.Count -eq 0) { continue }

    $ticketPath = Join-Path -Path $ExportPath -ChildPath $key
    if (-not (Test-Path $ticketPath)) {
        New-Item -Path $ticketPath -ItemType Directory | Out-Null
    }

    foreach ($attachment in $attachments) {
        $fileName = $attachment.filename
        $downloadUrl = $attachment.content
        $downloadPath = Join-Path -Path $ticketPath -ChildPath $fileName

        Write-Host "Downloading $fileName from $key..."
        try {
            Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $downloadPath
        }
        catch {
            Write-Host "Failed to download $fileName $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "Attachment export complete!" -ForegroundColor Cyan
