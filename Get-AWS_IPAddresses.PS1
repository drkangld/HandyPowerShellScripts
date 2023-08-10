### SETUP PARAMETERS
$AwsUrl = 'https://ip-ranges.amazonaws.com/ip-ranges.json'
$OutputFile = "C:\temp\amazon_ips-us-east.txt"

# Get the JSON file from Amazon with error handling
try {
     $response = Invoke-WebRequest -Uri $($AwsUrl) -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
} catch [System.Net.WebException] {
     Write-Host "An exception was caught: $($_.Exception.Message)" -ForegroundColor Red
     $_.Exception.Respose
}
# Convert JSON to a custom object
$ips = $response | ConvertFrom-Json
# Filter for US-EAST-1
$usEast1 =  $ips.prefixes | Where-Object {$_.region -like "us-east-1"}
# Output just the IP prefixes to a text file
$usEast1.ip_prefix | Out-File -FilePath $OutputFile
