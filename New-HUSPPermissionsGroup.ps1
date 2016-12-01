<#
    ################################################################
    .Synopsis
     Adds a new SharePoint group with an AD group or person in it
    .DESCRIPTION
     Creates a new group with a default permission set for a site
    .Parameter web
     A valid SharePoint site collection
    .Parameter ad
     A valid AD group or member
    .Parameter name
     The name you want for the group
    .Parameter description
     The description for the group you are creating
    .Parameter permission
     A valid SharePoint Permission level you want to appply
    .OUTPUTS
     Adds a group to the site collection groups with default permissions and members stated
    .EXAMPLE 
     New-HUSPPermissionsGroup -web https://devunifunctions.hud.ac.uk/COM -ad AD\staff_allstaff -name "My Test Group" -description "My testing group" -permission "UF Read"
    ################################################################
#>

function New-HUSPPermissionsGroup {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$web,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$ad,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$name,
        [Parameter(Mandatory=$True,Position=4)]
        [string]$description,
        [Parameter(Mandatory=$True,Position=5)]
        [string]$permission
        )

    $ADMember = $ad
    $SPGroupName = $name
    $SPGroupDescription = $description
    $SPGroupPermission = $permission
    
    $SPWeb = Get-SPWeb $web

    #Check if the group already exists
    if ($SPWeb.IsRootWeb -eq $true) {

        if ($SPWeb.SiteGroups[$SPGroupName] -eq $null) {
            #Ensure Group/User is part of site collection users beforehand and add them if needed
            $SPWeb.EnsureUser($ADMember)
    
            # This MOFO took me ages to format
            $SPClaimsUser = $SPWeb.EnsureUser($ADMember) | Select -ExpandProperty UserLogin
    
            Write-Verbose $SPClaimsUser
    
            # Get the AD Group/User in a format that PowerShell can use otherwise there will be a string error
            $ADMemberSPFriendly = $SPWeb | Get-SPUser $SPClaimsUser
    
            #Create the SharePoint Group – Group Name, Group Owner, Group Member, Group Description. Can’t add AD group yet…
            $NewSPGroup = $SPWeb.SiteGroups.Add($SPGroupName, $SPWeb.Author, $SPWeb.Author, $SPGroupDescription)
            $SPWeb.AssociatedGroups.Add($SPWeb.SiteGroups[$SPGroupName])
            $NewSPAccount = $SPWeb.SiteGroups[$SPGroupName]
    
            #Assign the Group permission
            $GroupAssignment = New-Object Microsoft.SharePoint.SPRoleAssignment($NewSPAccount)
            $GroupRole = $SPWeb.RoleDefinitions[$SPGroupPermission]
            $GroupAssignment.RoleDefinitionBindings.Add($GroupRole)
            $SPWeb.RoleAssignments.Add($GroupAssignment)
    
            #Add the AD Group/User to the group, can’t be done during group creation when using Powershell otherwise errors so is done now.
            Set-SPUser -Identity $ADMemberSPFriendly -Web $SPWeb -Group $SPGroupName
        } else {
            Write-Output "$SPGroupName already exists"
        }
    } else {
            Write-Output "$SPWeb is not a site collection"
    }
    
    $SPWeb.Dispose()

}