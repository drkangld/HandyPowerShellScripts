
# Load PSWriteHTML module
$module = Get-Module -ListAvailable PSWriteHTML | Sort-Object Version -Descending | Select-Object -First 1
Import-Module $module.Path -force

# Set tenancy OCID (replace with your actual tenancy OCID)
Write-Host "Setting Tenancy..." 
$tenancyId = '<tenancyIDHere>'
Write-Host "Tenancy: $tenancyId" -ForegroundColor Yellow

# Initialize collections
Write-Host "Initializing collections..."
$groupDetails = @()
$userGroupMap = @{}
$dynGroupDetails = @()
$tenancyPolicyDetails = @()

# Output File Path
$outputFile = "<OutputPath"
Write-Host "Output file: $outputFile" -ForegroundColor Yellow

# Get all groups
Write-host "Getting groups..." -ForegroundColor Yellow
$groups = oci iam group list | ConvertFrom-Json
foreach ($group in $groups.data) {
    $users = oci iam group list-users --group-id $group.id | ConvertFrom-Json
    $groupDetails += [PSCustomObject]@{
        GroupName = $group.name
        GroupDescription = $group.description
        Users     = ($users.data | ForEach-Object { $_.name }) -join ", "
    }

    foreach ($user in $users.data) {
        if (-not $userGroupMap.ContainsKey($user.name)) {
            $userGroupMap[$user.name] = @()
        }
        $userGroupMap[$user.name] += $group.name
    }
}

# Convert user-to-groups map to array of objects
$userGroupDetails = @()
foreach ($user in $userGroupMap.Keys) {
    $userGroupDetails += [PSCustomObject]@{
        UserName = $user
        Groups   = ($userGroupMap[$user]) -join ", "
    }
}

# Get all dynamic groups
Write-Host "Getting Dynamic Groups..." -ForegroundColor Yellow
$dynGroups = oci iam dynamic-group list | ConvertFrom-Json
foreach ($dynGroup in $dynGroups.data) {
    $dynGroupDetails += [PSCustomObject]@{
        Name  = $dynGroup.name
        Description = $dynGroup.description
        Rules = $dynGroup."matching-rule"
    }
}
Write-Host " Groups:  $($($Groups.data).count)" -ForegroundColor Yellow
Write-Host " Dynamic Groups: $($($dynGroups.data).count)" -ForegroundColor Yellow

# Get tenancy-level policies
Write-Host "Getting tenancy policies..." -ForegroundColor Yellow
$tenancyPolicies = oci iam policy list --compartment-id $tenancyId | ConvertFrom-Json

$policySummary = foreach ($policy in $tenancyPolicies.data) {
    $policyName = $policy.name
    $policyCompartment = $policy.'compartment-id'
    $policyID = $policy.id
    $policyDescription = $policy.description

    foreach ($statement in $policy.statements) {
        if ($statement -match "Allow (.+) to (.+) in (.+)") {
            [PSCustomObject]@{
                PolicyName      = $policyName
                PolicyDescription = $policyDescription
                PolicyID        = $policyID
                #CompartmentID   = $policyCompartment
                Who             = $matches[1]
                Action          = $matches[2]
                Where           = $matches[3]
                ##RawStatement    = $statement
            }
        }
        else {
            # Capture unrecognized statements too, if you want
            [PSCustomObject]@{
                PolicyName      = $policyName
                PolicyDescription = $policyDescription
                PolicyID        = $policyID
                #CompartmentID   = $policyCompartment
                Who             = ""
                Action          = ""
                Where           = ""
                #RawStatement    = $statement
            }
        }
    }
}

# Now $policySummary contains all parsed policies in a flat list ready for PSWriteHTML
$policySummary 

# Generate HTML report
Write-Host "Generating Report..." -ForegroundColor Yellow
New-HTML -TitleText "OCI IAM Report" -Online -ShowHTML -FilePath $($outputFile) {
    New-HTMLHeader {
        New-HTMLText -Text "OCI IAM Information" -FontSize 28 -Color Navy -Align center
    }
    New-HTMLSection -HeaderText 'OCI Users and Groups' -HeaderTextSize 16 {
        New-HTMLTabPanel {
            New-HTMLTabStyle -RowElements 3 
            New-HTMLTab -Name 'OCI Users' -IconBrands acquisitions-incorporated -TextSize 16 -TextColor Black {
                New-HTMLTable -DataTable $userGroupDetails
            }
            New-HTMLTab -Name 'OCI Groups' -IconBrands acquisitions-incorporated -TextSize 16 -TextColor Black {
                New-HTMLTable -DataTable $groupDetails
            }
            New-HTMLTab -Name 'OCI Dynamic Groups' -IconBrands acquisitions-incorporated -TextSize 16 -TextColor Black {
                New-HTMLTable -DataTable $dynGroupDetails
            }
        }
    
    }
    New-HTMLSection -HeaderText 'OCI Policy Information' -HeaderTextSize 16 {
            New-HTMLTabStyle -RowElements 1
            New-HTMLTable -DataTable $policySummary
        

    }
    New-HTMLFooter {
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        New-HTMLText -Text "Stollen From Cris Martinez on $timestamp ~𐑃𐑉𐑋𐑕~" -Align right -Color '#777'
    }
}

