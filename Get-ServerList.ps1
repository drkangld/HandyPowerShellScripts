<#
.Synopsis
   Automatically creates a list of servers in an array for iteration
.DESCRIPTION
   Automatically creates a list of servers in an array for iteration
.EXAMPLE
   $RDSservers = Set-ServerList -PFX "BRKRDS" -count 24
   Returns an array of servers named BRKRDS1-24
.INPUTS
   PFX - Server name prefix
   Count - number of servers
.OUTPUTS
   An array containing the generated server names.
.NOTES
#>
function Set-ServerList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Server Prefix")]
        [string[]]$PFX,
        [Parameter(Mandatory = $true, HelpMessage = "Server Count")]
        [INT]$count
    )
    Process {
        $servers = @()
        For ($c = 1;$c -le $count;$c++) {
            $servers+=$($PFX).trim() +$c
        }
    }
    end {
            $servers
    }
}
