function Set-HUSPApplyGroupPermissionsSiteCollection {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$group,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$permission
        )

    $SPSite = Get-SPSite $url

    ForEach ($SPWeb in $SPSite.AllWebs) {

        If ($SPWeb.HasUniquePerm -eq $false) {
                Write-Host "Breaking inheritance for $SPWeb"
                $SPWeb.BreakRoleInheritance($true, $true)
            } else {
                Write-Host "Inheritance is broken for $SPWeb"
        }

        $SPGroup = $SPWeb.SiteGroups[$group]

        $GroupAssignment = new-object Microsoft.SharePoint.SPRoleAssignment($SPGroup)
        
        $RoleDefinition = $SPWeb.Site.RootWeb.RoleDefinitions[$permission]
        
        $GroupAssignment.RoleDefinitionBindings.Add($RoleDefinition)
        
        $SPWeb.RoleAssignments.Add($GroupAssignment)
        
        $SPWeb.Update()
    
        $SPWeb.Dispose()
    }

    $SPSite.Dispose()

}