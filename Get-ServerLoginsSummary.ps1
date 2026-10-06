<#
.SYNOPSIS
    Windows Server Interactive Logon Audit

.DESCRIPTION
    Audits successful interactive logons from the Windows Security log.

    Includes:
        Logon Type 2  = Interactive / Console
        Logon Type 10 = Remote Interactive / RDP

    Creates:
        1. Detailed CSV containing individual logon events
        2. Summary CSV containing one record per account

.NOTES
    Designed for Windows PowerShell 5.1.

    Run PowerShell as Administrator so the script can read
    the Windows Security event log.
#>


# ============================================================
# CONFIGURATION
# ============================================================

# Number of days to look back
$DaysBack = 365

# Output directory
$OutputPath = "C:\Temp\ServerLogonAudit"

# Logon types to include
# 2  = Interactive / Console
# 10 = Remote Interactive / RDP
$LogonTypes = @("2", "10")


# ============================================================
# INITIALIZATION
# ============================================================

$StartTime = (Get-Date).AddDays(-$DaysBack)
$ComputerName = $env:COMPUTERNAME

if (-not (Test-Path -Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

$DetailFile = Join-Path $OutputPath "$ComputerName-LogonDetail.csv"
$SummaryFile = Join-Path $OutputPath "$ComputerName-LogonSummary.csv"
$ErrorFile = Join-Path $OutputPath "$ComputerName-LogonErrors.csv"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Windows Server Interactive Logon Audit" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Server:     $ComputerName"
Write-Host "Start Date: $StartTime"
Write-Host "Days Back:  $DaysBack"
Write-Host ""


# ============================================================
# READ SECURITY EVENT LOG
# ============================================================

Write-Host "Reading Security event log..." -ForegroundColor Yellow
Write-Host ""

try {

    $Events = Get-WinEvent -FilterHashtable @{
        LogName   = "Security"
        Id        = 4624
        StartTime = $StartTime
    } -ErrorAction Stop

}
catch {

    Write-Host ""
    Write-Host "ERROR: Unable to read the Security event log." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure PowerShell is running as Administrator." -ForegroundColor Yellow
    Write-Host ""

    exit 1
}

Write-Host "4624 events found: $($Events.Count)" -ForegroundColor Green
Write-Host ""
Write-Host "Processing interactive logons..." -ForegroundColor Yellow
Write-Host ""


# ============================================================
# PROCESS EVENTS
# ============================================================

$Results = @()
$ProcessingErrors = @()

foreach ($Event in $Events) {

    try {

        # ----------------------------------------------------
        # Convert event to XML
        # ----------------------------------------------------

        $EventXML = [xml]$Event.ToXml()

        $EventData = @{}


        # ----------------------------------------------------
        # Build a hash table containing the named event fields
        # ----------------------------------------------------

        foreach ($DataItem in $EventXML.Event.EventData.Data) {

            $DataName = $DataItem.Name

            if ($null -ne $DataName) {

                $DataValue = $DataItem.'#text'

                $EventData[$DataName] = $DataValue
            }
        }


        # ----------------------------------------------------
        # Get important fields
        # ----------------------------------------------------

        $LogonType = $EventData["LogonType"]
        $UserName = $EventData["TargetUserName"]
        $Domain = $EventData["TargetDomainName"]


        # ----------------------------------------------------
        # We only care about interactive logons
        # ----------------------------------------------------

        if ($LogonTypes -notcontains $LogonType) {
            continue
        }


        # ----------------------------------------------------
        # Skip missing user names
        # ----------------------------------------------------

        if ($null -eq $UserName) {
            continue
        }

        $UserName = $UserName.ToString().Trim()

        if ($UserName.Length -eq 0) {
            continue
        }


        # ----------------------------------------------------
        # Skip computer accounts
        #
        # AD computer accounts normally end in $
        # ----------------------------------------------------

        if ($UserName -match '\$$') {
            continue
        }


        # ----------------------------------------------------
        # Skip common Windows identities
        # ----------------------------------------------------

        if (
            $UserName -eq "SYSTEM" -or
            $UserName -eq "LOCAL SERVICE" -or
            $UserName -eq "NETWORK SERVICE" -or
            $UserName -eq "ANONYMOUS LOGON"
        ) {
            continue
        }


        # ----------------------------------------------------
        # Clean domain name
        # ----------------------------------------------------

        if ($null -ne $Domain) {

            $Domain = $Domain.ToString().Trim()
        }


        # ----------------------------------------------------
        # Generate friendly logon type
        # ----------------------------------------------------

        switch ($LogonType) {

            "2" {
                $LogonTypeName = "Interactive (Console)"
            }

            "10" {
                $LogonTypeName = "RemoteInteractive (RDP)"
            }

            default {
                $LogonTypeName = "Other"
            }
        }


        # ----------------------------------------------------
        # Build DOMAIN\User account name
        # ----------------------------------------------------

        if ($null -ne $Domain -and $Domain.Length -gt 0) {

            $Account = $Domain + "\" + $UserName
        }
        else {

            $Account = $UserName
        }


        # ----------------------------------------------------
        # Get optional event properties safely
        # ----------------------------------------------------

        $SourceIPAddress = $EventData["IpAddress"]
        $SourcePort = $EventData["IpPort"]
        $WorkstationName = $EventData["WorkstationName"]
        $AuthenticationPackage = $EventData["AuthenticationPackageName"]
        $LogonProcess = $EventData["LogonProcessName"]
        $LogonID = $EventData["TargetLogonId"]


        # ----------------------------------------------------
        # Create detailed result record
        # ----------------------------------------------------

        $Result = New-Object PSObject -Property @{

            TimeCreated = $Event.TimeCreated

            Server = $ComputerName

            Account = $Account

            UserName = $UserName

            Domain = $Domain

            LogonType = $LogonType

            LogonTypeName = $LogonTypeName

            SourceIPAddress = $SourceIPAddress

            SourcePort = $SourcePort

            WorkstationName = $WorkstationName

            AuthenticationPackage = $AuthenticationPackage

            LogonProcess = $LogonProcess

            LogonID = $LogonID

            EventRecordID = $Event.RecordId
        }

        $Results += $Result

    }
    catch {

        # ----------------------------------------------------
        # Save actual processing error
        # ----------------------------------------------------

        $ErrorMessage = $_.Exception.Message

        $ErrorRecord = New-Object PSObject -Property @{

            EventRecordID = $Event.RecordId

            TimeCreated = $Event.TimeCreated

            ErrorMessage = $ErrorMessage
        }

        $ProcessingErrors += $ErrorRecord


        # ----------------------------------------------------
        # Show useful warning
        # ----------------------------------------------------

        Write-Warning "Unable to process Event Record ID $($Event.RecordId)"
        Write-Warning "Time: $($Event.TimeCreated)"
        Write-Warning "Error: $ErrorMessage"
        Write-Host ""
    }
}


# ============================================================
# SORT RESULTS
# ============================================================

$Results = @(
    $Results |
        Sort-Object TimeCreated -Descending
)


# ============================================================
# DISPLAY EVENT PROCESSING RESULTS
# ============================================================

Write-Host ""
Write-Host "Processing complete." -ForegroundColor Green
Write-Host ""

Write-Host "4624 events examined:   $($Events.Count)"
Write-Host "Interactive events:     $($Results.Count)"
Write-Host "Processing errors:      $($ProcessingErrors.Count)"
Write-Host ""


# ============================================================
# EXPORT DETAILED REPORT
# ============================================================

if ($Results.Count -gt 0) {

    $Results |
        Select-Object `
            TimeCreated,
            Server,
            Account,
            UserName,
            Domain,
            LogonType,
            LogonTypeName,
            SourceIPAddress,
            SourcePort,
            WorkstationName,
            AuthenticationPackage,
            LogonProcess,
            LogonID,
            EventRecordID |
        Export-Csv `
            -Path $DetailFile `
            -NoTypeInformation `
            -Encoding UTF8
}
else {

    Write-Warning "No interactive logon events were found."
}


# ============================================================
# EXPORT PROCESSING ERRORS
# ============================================================

if ($ProcessingErrors.Count -gt 0) {

    $ProcessingErrors |
        Select-Object `
            EventRecordID,
            TimeCreated,
            ErrorMessage |
        Export-Csv `
            -Path $ErrorFile `
            -NoTypeInformation `
            -Encoding UTF8
}


# ============================================================
# CREATE USER SUMMARY
# ============================================================

$Summary = @()

if ($Results.Count -gt 0) {

    $Summary = @(
        $Results |
            Group-Object Account |
            ForEach-Object {

                $AccountGroup = $_
                $UserEvents = $AccountGroup.Group


                # --------------------------------------------
                # First login
                # --------------------------------------------

                $FirstLogin = (
                    $UserEvents |
                        Sort-Object TimeCreated |
                        Select-Object -First 1
                ).TimeCreated


                # --------------------------------------------
                # Last login
                # --------------------------------------------

                $LastLogin = (
                    $UserEvents |
                        Sort-Object TimeCreated -Descending |
                        Select-Object -First 1
                ).TimeCreated


                # --------------------------------------------
                # Unique source IP addresses
                # --------------------------------------------

                $SourceIPs = @()

                foreach ($UserEvent in $UserEvents) {

                    $IPAddress = $UserEvent.SourceIPAddress

                    if ($null -ne $IPAddress) {

                        $IPAddress = $IPAddress.ToString().Trim()

                        if (
                            $IPAddress.Length -gt 0 -and
                            $IPAddress -ne "-" -and
                            $IPAddress -ne "::1" -and
                            $IPAddress -ne "127.0.0.1"
                        ) {

                            $SourceIPs += $IPAddress
                        }
                    }
                }

                $SourceIPs = @(
                    $SourceIPs |
                        Sort-Object -Unique
                )


                # --------------------------------------------
                # Unique workstation names
                # --------------------------------------------

                $Workstations = @()

                foreach ($UserEvent in $UserEvents) {

                    $Workstation = $UserEvent.WorkstationName

                    if ($null -ne $Workstation) {

                        $Workstation = $Workstation.ToString().Trim()

                        if (
                            $Workstation.Length -gt 0 -and
                            $Workstation -ne "-"
                        ) {

                            $Workstations += $Workstation
                        }
                    }
                }

                $Workstations = @(
                    $Workstations |
                        Sort-Object -Unique
                )


                # --------------------------------------------
                # Unique logon methods
                # --------------------------------------------

                $Methods = @(
                    $UserEvents |
                        Select-Object `
                            -ExpandProperty LogonTypeName `
                            -Unique
                )


                # --------------------------------------------
                # Count console logons
                # --------------------------------------------

                $ConsoleLogons = @(
                    $UserEvents |
                        Where-Object {
                            $_.LogonType -eq "2"
                        }
                ).Count


                # --------------------------------------------
                # Count RDP logons
                # --------------------------------------------

                $RDPLogons = @(
                    $UserEvents |
                        Where-Object {
                            $_.LogonType -eq "10"
                        }
                ).Count


                # --------------------------------------------
                # Generate summary record
                # --------------------------------------------

                $SummaryRecord = New-Object PSObject -Property @{

                    Account = $AccountGroup.Name

                    FirstLogin = $FirstLogin

                    LastLogin = $LastLogin

                    LoginCount = $AccountGroup.Count

                    ConsoleLogins = $ConsoleLogons

                    RDPLogins = $RDPLogons

                    LogonMethods = ($Methods -join "; ")

                    SourceIPs = ($SourceIPs -join "; ")

                    Workstations = ($Workstations -join "; ")
                }

                $SummaryRecord
            } |
            Sort-Object LastLogin -Descending
    )
}


# ============================================================
# EXPORT SUMMARY REPORT
# ============================================================

if ($Summary.Count -gt 0) {

    $Summary |
        Select-Object `
            Account,
            FirstLogin,
            LastLogin,
            LoginCount,
            ConsoleLogins,
            RDPLogins,
            LogonMethods,
            SourceIPs,
            Workstations |
        Export-Csv `
            -Path $SummaryFile `
            -NoTypeInformation `
            -Encoding UTF8
}


# ============================================================
# DISPLAY SUMMARY
# ============================================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " Audit Complete" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Server:               $ComputerName"
Write-Host "Days audited:         $DaysBack"
Write-Host "4624 events examined: $($Events.Count)"
Write-Host "Interactive events:   $($Results.Count)"
Write-Host "Unique accounts:      $($Summary.Count)"
Write-Host "Processing errors:    $($ProcessingErrors.Count)"
Write-Host ""


# ============================================================
# SHOW USER SUMMARY
# ============================================================

if ($Summary.Count -gt 0) {

    $Summary |
        Select-Object `
            Account,
            FirstLogin,
            LastLogin,
            LoginCount,
            ConsoleLogins,
            RDPLogins |
        Format-Table -AutoSize
}


# ============================================================
# OUTPUT FILE LOCATIONS
# ============================================================

Write-Host ""

if (Test-Path $DetailFile) {

    Write-Host "Detailed Report:" -ForegroundColor Cyan
    Write-Host $DetailFile
    Write-Host ""
}

if (Test-Path $SummaryFile) {

    Write-Host "Summary Report:" -ForegroundColor Cyan
    Write-Host $SummaryFile
    Write-Host ""
}

if (Test-Path $ErrorFile) {

    Write-Host "Processing Error Report:" -ForegroundColor Yellow
    Write-Host $ErrorFile
    Write-Host ""
}

Write-Host "Done." -ForegroundColor Green
Write-Host ""
