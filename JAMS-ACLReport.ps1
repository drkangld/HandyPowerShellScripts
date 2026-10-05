Import-Module JAMS

New-PSDrive JDB JAMS BRKJAMSQC2

#
# Adjust below line to change output path
#
Start-Transcript -Path F:\JAMSQC3_Logs\PermissionReport.txt


# ============================================================
# Permissions lookup tables
# ============================================================

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


$VARS_ACCESS = @{
    [MVPSI.JAMS.VariableRights]::Change  = "Change"
    [MVPSI.JAMS.VariableRights]::Control = "Control"
    [MVPSI.JAMS.VariableRights]::Delete  = "Delete"
    [MVPSI.JAMS.VariableRights]::Inquire = "Inquire"
}


$AGENT_ACCESS = @{
    [MVPSI.JAMS.AgentAccess]::Change  = "Change"
    [MVPSI.JAMS.AgentAccess]::Control = "Control"
    [MVPSI.JAMS.AgentAccess]::Delete  = "Delete"
    [MVPSI.JAMS.AgentAccess]::Inquire = "Inquire"
    [MVPSI.JAMS.AgentAccess]::Manage  = "Manage"
    [MVPSI.JAMS.AgentAccess]::Submit  = "Submit"
}


$BATCH_ACCESS = @{
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


$RUNAS_ACCESS = @{
    [MVPSI.JAMS.UserAccess]::Change      = "Change"
    [MVPSI.JAMS.UserAccess]::Control     = "Control"
    [MVPSI.JAMS.UserAccess]::GetPassword = "GetPassword"
    [MVPSI.JAMS.UserAccess]::Submit      = "Submit"
}


# ============================================================
# Convert AccessBits into readable permission names
# ============================================================

function generateReadableACE {

    param(
        $permsDict,
        $ace
    )

    $result = ""

    foreach ($key in $permsDict.Keys) {

        if (($key -band $ace) -ne 0) {
            $result += " " + $permsDict[$key]
        }
    }

    if ($result.Length -eq 0) {
        $result = "No access permissions set"
    }

    return $result.Trim()
}


# ============================================================
# Folder Permissions
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = ="
Write-Host "Displaying Folder permissions..."
Write-Host "= = = = = = = = = = = = = = = = =`n"


$folderList = Get-ChildItem "JDB:\" `
    -Recurse `
    -IgnorePredefined `
    -ObjectType folder


foreach ($folder in $folderList) {

    Write-Output "Folder: $($folder.QualifiedName)"

    #
    # FIX:
    # $folder is already the complete JAMS folder object.
    # Do NOT retrieve it again with Get-Item using QualifiedName.
    #

    foreach ($ace in $folder.Acl.GenericACL) {

        $accessNames = generateReadableACE `
            $FOLDER_ACCESS `
            $ace.AccessBits

        Write-Output "  Identifier: $($ace.Identifier)"
        Write-Output "  Access: $accessNames"
        Write-Output ""
    }
}


$folderList = $null


# ============================================================
# Job Permissions
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = ="
Write-Host "Displaying Job permissions..."
Write-Host "= = = = = = = = = = = = = = = = =`n"


$objectList = Get-ChildItem "JDB:\" `
    -ObjectType job `
    -Recurse `
    -IgnorePredefined


foreach ($object in $objectList) {

    Write-Output "Job: $($object.QualifiedName)"

    foreach ($ace in $object.Acl.GenericACL) {

        $accessNames = generateReadableACE `
            $JOB_ACCESS `
            $ace.AccessBits

        Write-Output "  Identifier: $($ace.Identifier)"
        Write-Output "  Access: $accessNames"
        Write-Output ""
    }
}


$objectList = $null


# ============================================================
# Variable Permissions
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Variable permissions..."
Write-Host "= = = = = = = = = = = = = = = = = =`n"


try {

    $varList = Get-ChildItem "JDB:\" `
        -ObjectType variable `
        -Recurse `
        -IgnorePredefined


    foreach ($var in $varList) {

        Write-Output "Variable: $($var.QualifiedName)"

        #
        # FIX:
        # $var is already the complete JAMS variable object.
        # Do NOT retrieve it again with Get-Item.
        #

        foreach ($ace in $var.ACL.GenericACL) {

            $accessNames = generateReadableACE `
                $VARS_ACCESS `
                $ace.AccessBits

            Write-Output "  Identifier: $($ace.Identifier)"
            Write-Output "  Access: $accessNames"
            Write-Output ""
        }
    }
}
catch {

    #
    # Log any errors
    #

    $_.Exception

    if ($_.Exception.InnerException.ValidationLog) {
        $_.Exception.InnerException.ValidationLog.Entries
    }
}


$varList = $null


# ============================================================
# Agent Permissions
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Agent permissions..."
Write-Host "= = = = = = = = = = = = = = = = = =`n"


$objectList = Get-ChildItem "JDB:\Agents\"


foreach ($object in $objectList) {

    Write-Output "Agent: $($object.AgentName)"

    foreach ($ace in $object.Acl.GenericACL) {

        $accessNames = generateReadableACE `
            $AGENT_ACCESS `
            $ace.AccessBits

        Write-Output "  Identifier: $($ace.Identifier)"
        Write-Output "  Access: $accessNames"
        Write-Output ""
    }
}


$objectList = $null


# ============================================================
# Batch Queue Permissions
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Batch Queue permissions..."
Write-Host "= = = = = = = = = = = = = = = = = = =`n"


$objectList = Get-ChildItem "JDB:\Queues\"


foreach ($object in $objectList) {

    Write-Output "Queue: $($object.QueueName)"

    foreach ($ace in $object.Acl.GenericACL) {

        $accessNames = generateReadableACE `
            $BATCH_ACCESS `
            $ace.AccessBits

        Write-Output "  Identifier: $($ace.Identifier)"
        Write-Output "  Access: $accessNames"
        Write-Output ""
    }
}


$objectList = $null


# ============================================================
# Resource Permissions
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Resource permissions..."
Write-Host "= = = = = = = = = = = = = = = = = =`n"


$objectList = Get-ChildItem "JDB:\Resources\"


foreach ($object in $objectList) {

    Write-Output "Resource: $($object.ResourceName)"

    if ($object.ACL.IsNull) {

        Write-Output "`tNo access permissions defined"

    }
    else {

        foreach ($ace in $object.Acl.GenericACL) {

            #
            # FIX:
            # Original JAMS script used $BATCH_ACCESS here.
            # Resources need $RESOURCE_ACCESS.
            #

            $accessNames = generateReadableACE `
                $RESOURCE_ACCESS `
                $ace.AccessBits

            Write-Output "`tIdentifier: $($ace.Identifier)"
            Write-Output "`tAccess: $accessNames"
            Write-Output ""
        }
    }
}


$objectList = $null


# ============================================================
# Credential Permissions
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Credential permissions..."
Write-Host "= = = = = = = = = = = = = = = = = = = = = = =`n"


$objectList = Get-ChildItem "JDB:\Credentials\"


foreach ($object in $objectList) {

    Write-Output "User: $($object.Name)"

    if ($object.ACL.IsNull) {

        Write-Output "`tNo access permissions defined"

    }
    else {

        foreach ($ace in $object.Acl.GenericACL) {

            $accessNames = generateReadableACE `
                $RUNAS_ACCESS `
                $ace.AccessBits

            Write-Output "  Identifier: $($ace.Identifier)"
            Write-Output "  Access: $accessNames"
            Write-Output ""
        }
    }
}


$objectList = $null


# ============================================================
# Complete
# ============================================================

Write-Host "`n= = = = = = = = = = = = = = = = = = = = = = ="
Write-Host "Permissions list completed."
Write-Host "= = = = = = = = = = = = = = = = = = = = = = ="


Remove-PSDrive JDB

Stop-Transcript
