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

function Set-HUSPDocumentLibraryPermissions {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$list,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$account,
    [Parameter(Mandatory=$True,Position=4)]
    [string]$level
    )
    
    $SPWeb = Get-SPWeb $url
    $SPAccount = $SPWeb.EnsureUser($account)
    $SPFriendlyAccount = $SPWeb | Get-SPUser $SPAccount
    $SPRole = $SPWeb.RoleDefinitions[$level]

    $SPList = $SPWeb.Lists[$list]

    $SPAssignment = New-Object Microsoft.SharePoint.SPRoleAssignment($SPFriendlyAccount)
    $SPAssignment.RoleDefinitionBindings.Add($SPRole)
    $SPList.RoleAssignments.Add($SPAssignment)

    Write-Host "Added $SPFriendlyAccount to $SPList with $SPRole permissions"

    $SPWeb.Dispose()
}