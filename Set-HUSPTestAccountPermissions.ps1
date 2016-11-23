<#
    ################################################################
    .Synopsis
     A brief outline of what the script does
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter url
     A description of the url parameter
    .Parameter list
     A description of the url parameter
    .OUTPUTS
     A description of what the script outputs
    .EXAMPLE 
     An example of the command in use
    ################################################################
#>

function Set-HUSPTestAccountPermissions {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url
    )
        
    $SPWeb = Get-SPWeb $url

    ForEach ( $SPLib in $SPWeb.Lists | Where { $_.Title -NotLike "@*" -and $_.Title -NotLike "Workflow*" -and $_.Hidden -eq $false} ) {
        Write-Verbose -message $SPLib.Title
    }

    $SPWeb.Dispose()
}    