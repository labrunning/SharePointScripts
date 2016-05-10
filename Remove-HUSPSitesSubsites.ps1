<# 
    .Synopsis
     A brief outline of what the script does
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter web
      The Web Application
    .Parameter list
      The list to act on
    .OUTPUTS
      This is a description of what the script outputs
    .EXAMPLE 
      My-Script -web -list
      Does what the script does
    .LINK
      A link (usually a link to where I stoled the script from)
#>    

function Remove-HUSPSitesSubsites {

    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$web
    )

    $SPWeb = Get-SPWeb $web
    
    Write-Host "You are about to delete the following site and ALL SUBSITES;"
    $web
    $ConfirmCreateSites = Read-Host "Are you Sure You Want To Proceed: (press 'y' to proceed)"

    If ($ConfirmCreateSites -eq 'y') {
        $SubWebs = $SPWeb.GetSubwebsForCurrentUser()
        ForEach($SubWeb in $SubWebs) {
            Write-Verbose "Removing site ($($SubWeb.Url))..."
            Remove-SPWeb $SubWeb -Confirm:$false
            $SubWeb.Dispose()
        }
    }

    $SPWeb.Dispose()
}