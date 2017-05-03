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
    .Parameter group
     A description of the url parameter
    .Parameter params
     A description of the url parameter
    .OUTPUTS
     A description of what the script outputs
    .EXAMPLE 
     An example of the command in use
    ################################################################
#>
    

function Add-HUSPGroupToList {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$group,
        [Parameter(Mandatory=$True,Position=4)]
        [string]$perms
    )

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    # Modify the permissions.
    If ($SPWeb.SiteGroups[$group] -ne $null) {
        $SPGroup = $SPWeb.SiteGroups[$group]
        $SPRoleAssignment = New-Object Microsoft.SharePoint.SPRoleAssignment($SPGroup)
        $SPRoleDefinition = $SPWeb.RoleDefinitions[$perms];
        $SPRoleAssignment.RoleDefinitionBindings.Add($SPRoleDefinition);
        $SPList.RoleAssignments.Add($SPRoleAssignment)
        $SPList.Update();
        Write-Host "Successfully added $perms permission to $group group in $list list. " -foregroundcolor Green
    } else {
        Write-Host "Group $group does not exist." -foregroundcolor Red
    }
    $SPWeb.Dispose()
}