Import-Module JAMS

cls

$jamsServer = "<JAMSSERVERNAME>"
$JAMSReportFile = "<Path>-$jamsServer.csv"

try {
    if ($null -eq (Get-PSDrive JD -ErrorAction SilentlyContinue)) {
        New-PSDrive JD JAMS $jamsServer -Scope Local
    }
}
catch {
    New-PSDrive JD JAMS $jamsServer -Scope Local
}


# ------------------------------------------------------------
# Get all JAMS Scheduler folders except the Samples folder
# ------------------------------------------------------------

$JAMSFolders = Get-ChildItem JD:\* `
    -ObjectType Folder `
    -IgnorePredefined `
    -FullObject |
    Where-Object { $_.QualifiedName -ne "\Samples" }


# ------------------------------------------------------------
# Initialize report
# ------------------------------------------------------------

$Report   = @()
$JobCount = 0


# ------------------------------------------------------------
# Process folders
# ------------------------------------------------------------

foreach ($JAMSFolder in $JAMSFolders) {

    # Get all jobs in this folder recursively
    $Jobs = Get-ChildItem `
        -Path "JD:\$($JAMSFolder.Name)" `
        -Recurse `
        -ObjectType Job `
        -FullObject


    foreach ($Job in $Jobs) {

        # ----------------------------------------------------
        # Job Enabled Status
        # ----------------------------------------------------

        $IsEnabled = $Job.Properties |
            Where-Object { $_.PropertyName -eq "Enabled" } |
            Select-Object -ExpandProperty Value


        # ----------------------------------------------------
        # Extract Team Owner
        # ----------------------------------------------------

        $JAMSTeam = ($Job.QualifiedFolderName.Split("\/"))[1]


        # ----------------------------------------------------
        # Get Schedule Trigger Information
        #
        # JAMS 7.1 exposes these through Job.Elements.
        # Only grab actual Trigger elements defined on the Job.
        # ----------------------------------------------------

        $ScheduleTriggers = $Job.Elements |
            Where-Object {
                $_.ElementKind -eq "Trigger" -and
                $_.Inherited -eq $false
            }


        # A job can potentially contain multiple triggers,
        # so combine them using a semicolon.

        if ($ScheduleTriggers) {

            $ScheduleType = (
                $ScheduleTriggers |
                ForEach-Object { $_.ElementTypeName }
            ) -join "; "

            $ScheduleDescription = (
                $ScheduleTriggers |
                ForEach-Object { $_.Description }
            ) -join "; "

            $ScheduleEnabled = (
                $ScheduleTriggers |
                ForEach-Object { $_.Enabled }
            ) -join "; "
        }
        else {

            $ScheduleType        = ""
            $ScheduleDescription = ""
            $ScheduleEnabled     = ""
        }


        # ----------------------------------------------------
        # Add Job to Report
        # ----------------------------------------------------

        $Report += [PSCustomObject]@{

            JAMSServer          = $jamsServer
            JAMSFolderName      = $Job.QualifiedFolderName
            JAMSTeam            = $JAMSTeam
            JAMSJobName         = $Job.Name
            JAMSAgentName       = $Job.AgentName
            ExecutionMethod     = $Job.MethodName
            Enabled             = $IsEnabled

            ScheduleType        = $ScheduleType
            ScheduleDescription = $ScheduleDescription
            ScheduleEnabled     = $ScheduleEnabled

            LastError           = $Job.LastError
            LastSuccess         = $Job.LastSuccess
        }


        $JobCount++
    }
}


# ------------------------------------------------------------
# Export Report
# ------------------------------------------------------------

$Report |
    Export-Csv `
        -Path $JAMSReportFile `
        -NoTypeInformation `
        -Force


# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

Write-Output ""
Write-Output "JAMS Total Job Count: $JobCount"
Write-Output "Report created: $JAMSReportFile"
Write-Output ""
Write-Output "Removing PSDrive"

Remove-PSDrive -Name JD
