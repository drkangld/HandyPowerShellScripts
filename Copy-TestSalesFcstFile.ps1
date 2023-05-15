    #Setup Parameters
    $sourceDirectory = "\\met.globaltti.net\applicationdata\Oracle\NON_PROD\QC\temp"
    $SourceFile = "SupplyForecast_Test.csv"
    $targetDirectory = "\\met.globaltti.net\applicationdata\Oracle\NON_PROD\QC\SupplyForecast"
    $datestamp = Get-Date -Format 'yyyy-MM-dd'

    #Check if the test file we're copying from exists.  Exit if it is not there.
    if(![System.IO.File]::Exists($(Join-path -Path $sourceDirectory -ChildPath $SourceFile))) {
    throw (New-Object System.IO.FileNotFoundException("ERROR: File not found: $SourceFile", $SourcFile))
    }

    #If the test file is already there, skip the copy. Otherwise copy the template test file with a new timestamp suffix
    if(![System.IO.File]::Exists($(Join-Path -Path $targetDirectory -ChildPath "SupplyForecast_$datestamp.csv"))) {
        Write-Host "No file"
        Copy-Item $(Join-Path -Path $sourceDirectory -ChildPath $SourceFile) $(Join-path -Path $targetDirectory -ChildPath "SupplyForecast_$datestamp.csv")
    } Else {Write-Host "File Already Exists"}
