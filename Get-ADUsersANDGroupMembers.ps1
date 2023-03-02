#Setup
Clear-Host
$ADGroup = "AXGPRODAdmin"
$outFile = "C:\Temp\outfile.csv"
$webFile = "c:\Temp\webFile.html"    
#Clear out old files
if (Test-path -Path $outFile) {Clear-Content -Path $outFile}
if (Test-path -Path $webFile) {Clear-Content -Path $webFile}

#Function to return all members of a group (Name, SamAccountName, objectClass)
function Get-SpecificADGroupMembers {
    param (
        [string]$ADGroup
    )
    $GroupMembers = Get-ADGroupMember -Identity $ADGroup | Sort-Object -property ObjectClass,name | Select-Object name,SamAccountName,objectClass
    $GroupMembers
}
#Split Users and Child Groups out into Separate Objects, Capture child group members
function Get-UserGroupObjects {
    param (
        $GroupMembers
    )
    $DirectUsers = @()
    $ChildGroupMembers = @()
    $ChildGroups = [ordered]@{}
    $ChildGroupUsers = @()
    foreach ($member in $GroupMembers){
        $name = $($member.name)
        $SamAccountName = $($member.SamaccountName)
        $objClass = $($member.objectClass)
        if ($objClass -eq 'user'){
            write-host "$name, $objClass" -ForegroundColor green 
            Write-Output "$name,$objClass" | Add-Content -path $outFile
            $DirectUserAcct = $name + " (" + 'MET\' + $SamAccountName + ")"
        #Add to user array
        $DirectUsers += $DirectUserAcct
        } elseif ($objClass -eq 'group'){
            write-host "$name, $objClass" -ForegroundColor red
            Write-Output "$name,$objClass" | Add-Content -path $outFile
            $ChildGroupMembers = Get-SpecificADGroupMembers -ADGroup $name
            foreach ($subitem in $ChildGroupMembers){
                $Childname = $($subitem.name)
                $ChildSamAccountName = $($subitem.SamaccountName)
                #$ChildobjClass = $($subitem.objectClass)
                write-host " - $Childname, $ChildobjClass" -ForegroundColor Yellow
                Write-Output " - ,$Childname,$ChildobjClass" | Add-Content -path $outFile
                $ChildGroupUser = $Childname + " (" + 'MET\' + $ChildSamAccountName + ")"
                $ChildGroupUsers += $ChildGroupUser
                }
            $ChildGroups[$name] = $ChildGroupUsers | Sort-Object
            }

    }
    #$ChildGroups = $ChildGroups.GetEnumerator() | Sort-Object -Property key
    #Return 2 objects--array and hashtable contained within a hashtable to parse when returned
    [hashtable] $UsersAndGroups = @{
        DirectUsers = $DirectUsers
        ChildGroups = $ChildGroups
    }
    $UsersAndGroups
}

function New-HTMLReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object]$GroupCollection,
        [Parameter(Mandatory = $true)]
        [string]$ADGroup
    )
    #Setup Header, CSS stylesheet
    begin {
        $header =  @"
        <style>

        h1 {
            font-family: Arial, Helvetica, sans-serif;
            color: #e68a00;
            font-size: 28px;
        } 
        h2 {
            font-family: Arial, Helvetica, sans-serif;
            color: #000099;
            font-size: 16px;
        } 
        table {
            font-size: 12px;
            border: 0px; 
            font-family: Arial, Helvetica, sans-serif;
        } 
        td {
            padding: 4px;
            margin: 0px;
            border: 0;
        }
        th {
            background: #395870;
            background: linear-gradient(#49708f, #293f50);
            color: #fff;
            font-size: 11px;
            text-transform: uppercase;
            padding: 10px 15px;
            vertical-align: middle;
        }
        tbody tr:nth-child(even) {
            background: #f0f0f2;
        }

        #CreationDate {
            font-family: Arial, Helvetica, sans-serif;
            color: #ff3300;
            font-size: 12px;
        } 
        #InternalUse {
            font-family: Arial, Helvetica, sans-serif;
            font-weight: bold;
            color: #ff3300;
            font-size: 12px;
            text-align: center;
        }         
        .ONLINE {
            color: #008000;
        }
        .OFFLINE {
            color: #ff0000;
            font-weight: bold;
        }
    </style>
"@
    }
    
    process {
        $ReportTitle = "<h1>$ADGroup Security Group Report</h1>`r`n"
        #$envRefreshDate = "<h2>Refresh Date: $($AXCollection.$key.envRefreshDate.MKETESTTOINTDATETIME)</h2>"
        #$TXDatabaseName = "$($AXCollection.$key.TXDatabase)" | ConvertTo-Html -Fragment -PreContent "<h2>AX Database</h2>" -Property @{ l='AX Transactional Database'; e={ $_.ToString() }}
        #$CustomLogoSettings = $AXCollection.$key.CustomLogoSettings | ConvertTo-Html -Fragment -PreContent "<h2>CustomLogo Settings</h2>" -as list -Property SALESORDERREQUESTURI,CLIENTSECRET,CLIENTID,BATCHSIZe,WEBREQUESTACCEPT,WEBREQUESTKEEPALIVE,WEBREQUESTMETHOD,WEBREQUESTQUERYPARAM,MODIFIEDBY         
        #$GroupUsers = $GroupCollection.DirectUsers | Sort-Object | ConvertTo-Html -Fragment -Property @{ l='AD Group Users'; e={ $_}}
        $GroupUsers = $GroupCollection.DirectUsers | Sort-Object | ConvertTo-Html -Fragment -Property @{ l='AD Group Direct Users'; e={ $_}}
        $GroupUsers 
        $ChildGroups = "<table>`r`n<tr><th>Child Group</th><th>Users</th></tr>`r`n"
        foreach($key in $GroupCollection.ChildGroups.keys){
            $ChildGroupRow = "<tr><td>$key</td><td>&nbsp;</td>"
            $ChildGroups += $ChildGroupRow
            #$subTable = "<table>`r`n"
            foreach ($n in $GroupCollection.ChildGroups.$key){               
                $usrRows = "<tr><td>&nbsp;</td><td>$n</td></tr></tr>`r`n"
                #$subTable += $usrRows
                $ChildGroups += $usrRows
            }
        }
        $ChildGroups += "</table>"
        



    }
    
    end {
        #$ReportRunTime = "<p id='CreationDate'>Creation Date: $(Get-Date)"
        #$Report | ConvertTo-Html -Title $ReportTitle  -body "$SQLServerName $envTier $envOwner $envRefreshDate $ReportRunTime $TXDatabaseName $DatabasesOfInterest $EIFEnabled $EIFSettingsIN $EIFSettingsOut $Flintfox $HybrisSettings $CustomLogoSettings $SquareSettings $GetPaidSettings $DIXFSettings" -Head $header -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)<p id='InternalUse'>Milwaukee Tool &#169 Internal Use Only" | Out-file .\Report.$key.html
        $Report | ConvertTo-Html -Title "$ReportTitle"  -body "$ReportTitle $GroupUsers $ChildGroups"  -Head $header -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)<p id='InternalUse'>Milwaukee Tool &#169 Internal Use Only" | Out-file .\Report.$ADGroup.html
        Invoke-Item .\Report.$ADGroup.html
    }
}


#All members of parent Group
$AuditGroupMembers = Get-SpecificADGroupMembers -ADGroup $ADGroup
#Parse into Users and Groups
$GroupCollection = Get-UserGroupObjects -GroupMembers $AuditGroupMembers
#$GroupCollection.DirectUsers
#$GroupCollection.ChildGroups
New-HTMLReport -GroupCollection $GroupCollection -ADGroup $ADGroup




