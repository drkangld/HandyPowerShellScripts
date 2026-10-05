Import-Module JAMS -EA Continue
New-PSDrive JD JAMS <JAMSServerName> -ErrorAction SilentlyContinue


$CREDS_ACCESS = @{
    [MVPSI.JAMS.UserAccess]::Change      = "Change"
    [MVPSI.JAMS.UserAccess]::Control     = "Control"
    [MVPSI.JAMS.UserAccess]::GetPassword = "GetPassword"
    [MVPSI.JAMS.UserAccess]::Submit      = "Submit"
}


$CALS_ACCESS = @{
    [MVPSI.JAMS.CalendarAccess]::Change  = "Change"
    [MVPSI.JAMS.CalendarAccess]::Control = "Control"
    [MVPSI.JAMS.CalendarAccess]::Delete  = "Delete"
    [MVPSI.JAMS.CalendarAccess]::Inquire = "Inquire"
}


$VARS_ACCESS = @{
    [MVPSI.JAMS.VariableRights]::Change  = "Change"
    [MVPSI.JAMS.VariableRights]::Control = "Control"
    [MVPSI.JAMS.VariableRights]::Delete  = "Delete"
    [MVPSI.JAMS.VariableRights]::Decrypt = "Decrypt"
    [MVPSI.JAMS.VariableRights]::Inquire = "Inquire"
}


$JOB_ACCESS = @{
    [MVPSI.JAMS.JobAccess]::Abort   = "Abort"
    [MVPSI.JAMS.JobAccess]::Change  = "Change"
    [MVPSI.JAMS.JobAccess]::Control = "Control"
    [MVPSI.JAMS.JobAccess]::Debug   = "Debug"
    [MVPSI.JAMS.JobAccess]::Delete  = "Delete"
    [MVPSI.JAMS.JobAccess]::Inquire = "Inquire"
    [MVPSI.JAMS.JobAccess]::Manage  = "Manage"
    [MVPSI.JAMS.JobAccess]::Monitor = "Monitor"
    [MVPSI.JAMS.JobAccess]::Submit  = "Submit"
}


$AGENT_ACCESS = @{
    [MVPSI.JAMS.AgentAccess]::Change  = "Change"
    [MVPSI.JAMS.AgentAccess]::Control = "Control"
    [MVPSI.JAMS.AgentAccess]::Delete  = "Delete"
    [MVPSI.JAMS.AgentAccess]::Inquire = "Inquire"
    [MVPSI.JAMS.AgentAccess]::Manage  = "Manage"
    [MVPSI.JAMS.AgentAccess]::Submit  = "Submit"
}


$QUEUE_ACCESS = @{
    [MVPSI.JAMS.BatchQueueRights]::Change  = "Change"
    [MVPSI.JAMS.BatchQueueRights]::Control = "Control"
    [MVPSI.JAMS.BatchQueueRights]::Delete  = "Delete"
    [MVPSI.JAMS.BatchQueueRights]::Inquire = "Inquire"
    [MVPSI.JAMS.BatchQueueRights]::Manage  = "Manage"
    [MVPSI.JAMS.BatchQueueRights]::Submit  = "Submit"
}


$RESOURCE_ACCESS = @{
    [MVPSI.JAMS.ResourceRights]::Acquire = "Acquire"
    [MVPSI.JAMS.ResourceRights]::Change  = "Change"
    [MVPSI.JAMS.ResourceRights]::Control = "Control"
    [MVPSI.JAMS.ResourceRights]::Delete  = "Delete"
    [MVPSI.JAMS.ResourceRights]::Inquire = "Inquire"
}


$FOLDER_ACCESS = @{
    [MVPSI.JAMS.FolderAccess]::Delete      = "Delete"
    [MVPSI.JAMS.FolderAccess]::Control     = "Control"
    [MVPSI.JAMS.FolderAccess]::Change      = "Change"
    [MVPSI.JAMS.FolderAccess]::Inquire     = "Inquire"
    [MVPSI.JAMS.FolderAccess]::AddJobs     = "AddJobs"
    [MVPSI.JAMS.FolderAccess]::ChangeJobs  = "ChangeJobs"
    [MVPSI.JAMS.FolderAccess]::InquireJobs = "InquireJobs"
    [MVPSI.JAMS.FolderAccess]::DeleteJobs  = "DeleteJobs"
    [MVPSI.JAMS.FolderAccess]::Submit      = "Submit"
    [MVPSI.JAMS.FolderAccess]::Debug       = "Debug"
    [MVPSI.JAMS.FolderAccess]::Manage      = "Manage"
    [MVPSI.JAMS.FolderAccess]::Monitor     = "Monitor"
    [MVPSI.JAMS.FolderAccess]::Abort       = "Abort"
}


$objectAccessItems = @{
    [MVPSI.JAMS.ObjectAccess]::Abort   = "Abort"
    [MVPSI.JAMS.ObjectAccess]::Add     = "Add"
    [MVPSI.JAMS.ObjectAccess]::Change  = "Change"
    [MVPSI.JAMS.ObjectAccess]::Control = "Control"
    [MVPSI.JAMS.ObjectAccess]::Decrypt = "Decrypt"
    [MVPSI.JAMS.ObjectAccess]::Delete  = "Delete"
    [MVPSI.JAMS.ObjectAccess]::Execute = "Execute"
    [MVPSI.JAMS.ObjectAccess]::Inquire = "Inquire"
    [MVPSI.JAMS.ObjectAccess]::Manage  = "Manage"
    [MVPSI.JAMS.ObjectAccess]::SeeAll  = "SeeAll"
    [MVPSI.JAMS.ObjectAccess]::SeeOwn  = "SeeOwn"
}


# ============================================================
# Generate Access Object
#
# PATCH:
# Uses the permission array itself instead of substring
# searches against $resultString.
#
# This prevents:
#
#   AddJobs     from also matching Add
#   ChangeJobs  from also matching Change
#   DeleteJobs  from also matching Delete
#   InquireJobs from also matching Inquire
#
# Also fixes the original SeeOwn/Abort bug.
# ============================================================

function generateAccessObject {

    param(
        $thisArea,
        $permsDict,
        $ace
    )

    [System.Collections.ArrayList]$resultSet = @()

    foreach ($key in $permsDict.Keys) {

        if (($key -band $ace.AccessBits) -ne 0) {

            $permissionName = $permsDict[$key].Trim()

            $null = $resultSet.Add($permissionName)
        }
    }


    if ($resultSet.Count -eq 0) {

        $resultString = "No access permissions set"
    }
    else {

        $resultString = $resultSet -join " "
    }


    Write-Host "Area: $thisArea - Identifier: $($ace.Identifier) - Access: $resultString"


    if ($resultString -ne "No access permissions set") {

        $Area = $thisArea
        $User = "$($ace.Identifier)"


        # ----------------------------------------------------
        # PATCH:
        # Exact permission comparisons
        # ----------------------------------------------------

        if ($resultSet -contains "Abort") {
            $Abort = "X"
        }
        else {
            $Abort = ""
        }


        if ($resultSet -contains "Acquire") {
            $Acquire = "X"
        }
        else {
            $Acquire = ""
        }


        if ($resultSet -contains "Add") {
            $Add = "X"
        }
        else {
            $Add = ""
        }


        if ($resultSet -contains "AddJobs") {
            $AddJobs = "X"
        }
        else {
            $AddJobs = ""
        }


        if ($resultSet -contains "Change") {
            $Change = "X"
        }
        else {
            $Change = ""
        }


        if ($resultSet -contains "ChangeJobs") {
            $ChangeJobs = "X"
        }
        else {
            $ChangeJobs = ""
        }


        if ($resultSet -contains "Control") {
            $Control = "X"
        }
        else {
            $Control = ""
        }


        if ($resultSet -contains "Debug") {
            $Debug = "X"
        }
        else {
            $Debug = ""
        }


        if ($resultSet -contains "Decrypt") {
            $Decrypt = "X"
        }
        else {
            $Decrypt = ""
        }


        if ($resultSet -contains "Delete") {
            $Delete = "X"
        }
        else {
            $Delete = ""
        }


        if ($resultSet -contains "DeleteJobs") {
            $DeleteJobs = "X"
        }
        else {
            $DeleteJobs = ""
        }


        if ($resultSet -contains "Execute") {
            $Execute = "X"
        }
        else {
            $Execute = ""
        }


        if ($resultSet -contains "GetPassword") {
            $GetPassword = "X"
        }
        else {
            $GetPassword = ""
        }


        if ($resultSet -contains "Inquire") {
            $Inquire = "X"
        }
        else {
            $Inquire = ""
        }


        if ($resultSet -contains "InquireJobs") {
            $InquireJobs = "X"
        }
        else {
            $InquireJobs = ""
        }


        if ($resultSet -contains "Monitor") {
            $Monitor = "X"
        }
        else {
            $Monitor = ""
        }


        if ($resultSet -contains "Manage") {
            $Manage = "X"
        }
        else {
            $Manage = ""
        }


        if ($resultSet -contains "Submit") {
            $Submit = "X"
        }
        else {
            $Submit = ""
        }


        # ----------------------------------------------------
        # PATCH:
        # Original script checked SeeAllJobs even though the
        # ObjectAccess enumeration is called SeeAll.
        # ----------------------------------------------------

        if ($resultSet -contains "SeeAll") {
            $SeeAllJobs = "X"
        }
        else {
            $SeeAllJobs = ""
        }


        # ----------------------------------------------------
        # PATCH:
        # Original script incorrectly checked Abort here.
        # ----------------------------------------------------

        if ($resultSet -contains "SeeOwn") {
            $SeeOwnJobs = "X"
        }
        else {
            $SeeOwnJobs = ""
        }


        $accessObject = [PSCustomObject]@{

            Area        = $Area
            User        = $User

            Abort       = $Abort
            Acquire     = $Acquire
            Add         = $Add
            AddJobs     = $AddJobs
            Change      = $Change
            ChangeJobs  = $ChangeJobs
            Control     = $Control
            Debug       = $Debug
            Decrypt     = $Decrypt
            Delete      = $Delete
            DeleteJobs  = $DeleteJobs
            Execute     = $Execute
            GetPassword = $GetPassword
            Inquire     = $Inquire
            InquireJobs = $InquireJobs
            Manage      = $Manage
            Monitor     = $Monitor
            Submit      = $Submit
            SeeAllJobs  = $SeeAllJobs
            SeeOwnJobs  = $SeeOwnJobs
        }

        return $accessObject
    }


    return $null
}


# ============================================================
# Get an instance of the JAMS Server
#
# Leaving this as localhost just like the original vendor
# script because the script is running on the JAMS server.
# ============================================================

$jamsServer = [MVPSI.JAMS.Server]::GetServer("localhost")


[System.Collections.ArrayList]$auditObjects = @()


$accessitems = @(

    [MVPSI.JAMS.AccessObject]::AccessControl,
    [MVPSI.JAMS.AccessObject]::AgentDefinitions,
    [MVPSI.JAMS.AccessObject]::CalendarDefinitions,
    [MVPSI.JAMS.AccessObject]::Configuration,
    [MVPSI.JAMS.AccessObject]::CredentialDefinitions,
    [MVPSI.JAMS.AccessObject]::FolderDefinitions,
    [MVPSI.JAMS.AccessObject]::History,
    [MVPSI.JAMS.AccessObject]::Monitor,
    [MVPSI.JAMS.AccessObject]::JobDefinitions,
    [MVPSI.JAMS.AccessObject]::VariableDefinitions,
    [MVPSI.JAMS.AccessObject]::QueueDefinitions,
    [MVPSI.JAMS.AccessObject]::MenuDefinitions,
    [MVPSI.JAMS.AccessObject]::NamedTimeDefinitions,
    [MVPSI.JAMS.AccessObject]::Reporting,
    [MVPSI.JAMS.AccessObject]::ResourceDefinitions,
    [MVPSI.JAMS.AccessObject]::ServerAccess
)


# ============================================================
# Iterate through AccessObject enumeration
# ============================================================

foreach ($accessType in $accessitems) {


    # --------------------------------------------------------
    # Load security for this AccessObject
    # --------------------------------------------------------

    $sec = New-Object MVPSI.JAMS.Security

    [MVPSI.JAMS.Security]::Load(
        [ref]$sec,
        $accessType,
        $jamsServer
    )


    # ========================================================
    # CALENDARS
    # ========================================================

    if ($accessType -eq [MVPSI.JAMS.AccessObject]::CalendarDefinitions) {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        $calsList = Get-ChildItem JD:\Calendars\


        foreach ($cal in $calsList) {

            #
            # PATCH:
            # The object returned by Get-ChildItem already
            # contains the ACL. No second Get-Item required.
            #

            if (!($cal.ACL.IsNull)) {

                foreach ($ace in $cal.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Cal: $($cal.Name)" $CALS_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }


        $calsList = $null
    }


    # ========================================================
    # CREDENTIALS
    # ========================================================

    elseif ($accessType -eq [MVPSI.JAMS.AccessObject]::CredentialDefinitions) {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        $credsList = Get-ChildItem JD:\Credentials\


        foreach ($cred in $credsList) {

            if (!($cred.ACL.IsNull)) {

                foreach ($ace in $cred.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Cred: $($cred.Name)" $CREDS_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }


        $credsList = $null
    }


    # ========================================================
    # FOLDERS
    # ========================================================

    elseif ($accessType -eq [MVPSI.JAMS.AccessObject]::FolderDefinitions) {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        try {

            $folderList = Get-ChildItem JD:\ -ObjectType folder -Recurse -IgnorePredefined


            foreach ($folder in $folderList) {

                #
                # PATCH:
                #
                # REMOVED:
                #
                # $fullFolder = Get-Item JD:\$($folder.QualifiedName)
                #
                # Use the JAMS Folder object already returned by
                # Get-ChildItem.
                #

                foreach ($ace in $folder.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Folder: $($folder.QualifiedName)" $FOLDER_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }
        catch {

            $_.Exception


            if ($_.Exception.InnerException.ValidationLog) {

                $_.Exception.InnerException.ValidationLog.Entries
            }
        }


        $folderList = $null
    }


        # ========================================================
        # VARIABLES
        # ========================================================
 
        elseif ($accessType -eq [MVPSI.JAMS.AccessObject]::VariableDefinitions) {
 
 
        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        try {

            $varList = Get-ChildItem JD:\ -ObjectType variable -Recurse -IgnorePredefined


            foreach ($var in $varList) {

                #
                # PATCH:
                #
                # REMOVED:
                #
                # $fullV = Get-Item JD:\$($var.QualifiedName)
                #
                # Use the JAMS Variable object directly.
                #

                foreach ($ace in $var.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Var: $($var.QualifiedName)" $VARS_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }
        catch {

            $_.Exception


            if ($_.Exception.InnerException.ValidationLog) {

                $_.Exception.InnerException.ValidationLog.Entries
            }
        }


        $varList = $null
    }


    # ========================================================
    # JOBS
    #
    # PATCH:
    # This is the biggest path correction.
    #
    # The original script retrieved every Folder, reconstructed
    # its path, and then searched for Jobs beneath that path.
    #
    # Instead, ask the JAMS provider for every Job recursively
    # and use the returned Job objects directly.
    # ========================================================

    elseif ($accessType -eq [MVPSI.JAMS.AccessObject]::JobDefinitions) {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        try {

            #
            # PATCH:
            # Direct recursive Job enumeration.
            #

            $jobsList = Get-ChildItem JD:\ -ObjectType job -Recurse -IgnorePredefined


            foreach ($job in $jobsList) {

                #
                # PATCH:
                #
                # REMOVED:
                #
                # $fullJob = Get-Item JD:\$($job.QualifiedName)
                #
                # The returned Job object already contains ACL.
                #

                foreach ($ace in $job.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Job: $($job.QualifiedName)" $JOB_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }
        catch {

            $_.Exception


            if ($_.Exception.InnerException.ValidationLog) {

                $_.Exception.InnerException.ValidationLog.Entries
            }
        }


        $jobsList = $null
    }


    # ========================================================
    # AGENTS
    # ========================================================

    elseif ($accessType -eq [MVPSI.JAMS.AccessObject]::AgentDefinitions) {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        $agentsList = Get-ChildItem JD:\Agents\


        foreach ($agent in $agentsList) {


            if (!($agent.ACL.IsNull)) {

                foreach ($ace in $agent.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Agent: $($agent.AgentName)" $AGENT_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }


        $agentsList = $null
    }


    # ========================================================
    # QUEUES
    # ========================================================

    elseif ($accessType -eq [MVPSI.JAMS.AccessObject]::QueueDefinitions) {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        $queueList = Get-ChildItem JD:\Queues\


        foreach ($queue in $queueList) {


            if (!($queue.ACL.IsNull)) {

                foreach ($ace in $queue.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Queue: $($queue.Name)" $QUEUE_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }


        $queueList = $null
    }


    # ========================================================
    # RESOURCES
    # ========================================================

    elseif ($accessType -eq [MVPSI.JAMS.AccessObject]::ResourceDefinitions) {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }


        $resourceList = Get-ChildItem JD:\Resources\


        foreach ($resource in $resourceList) {


            if (!($resource.ACL.IsNull)) {

                foreach ($ace in $resource.ACL.GenericACL) {

                    $accessObject = GenerateAccessObject "Resource: $($resource.Name)" $RESOURCE_ACCESS $ace

                    if ($accessObject) {

                        $null = $auditObjects.Add($accessObject)

                        $accessObject = $null
                    }
                }
            }
        }


        $resourceList = $null
    }


    # ========================================================
    # All other global Security Areas
    #
    # ServerAccess
    # Reporting
    # NamedTimeDefinitions
    # MenuDefinitions
    # History
    # AccessControl
    # Monitor
    # Configuration
    # ========================================================

    else {


        foreach ($ace in $sec.Acl.GenericACL) {

            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace

            if ($accessObject) {

                $null = $auditObjects.Add($accessObject)

                $accessObject = $null
            }
        }
    }
}


# ============================================================
# Output
# ============================================================

$auditObjects | Format-Table

$auditObjects |
    Export-Csv -Path F:\Reports\FullJAMSAuditReport.csv -NoTypeInformation


# ============================================================
# Cleanup
# ============================================================

Remove-PSDrive JD
