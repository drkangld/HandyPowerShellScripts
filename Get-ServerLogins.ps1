Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id      = 4624
} | ForEach-Object {

    $EventXml = [xml]$_.ToXml()
    $Data = @{}

    foreach ($Item in $EventXml.Event.EventData.Data) {
        $Data[$Item.Name] = $Item.'#text'
    }

    if ($Data.LogonType -in '2','10') {
        [PSCustomObject]@{
            TimeCreated = $_.TimeCreated
            User        = $Data.TargetUserName
            Domain      = $Data.TargetDomainName
            LogonType   = $Data.LogonType
            SourceIP    = $Data.IpAddress
            Workstation = $Data.WorkstationName
        }
    }

} | Sort-Object TimeCreated -Descending |
    Format-Table -AutoSize
