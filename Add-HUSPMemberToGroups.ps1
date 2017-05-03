<#
    .SYNOPSIS
     A brief outline of what the script does
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter url
     A valid SharePoint site
    .Parameter list
     A valid SharePoint list
    .Parameter level
     A valid SharePoint permissions level
    .Parameter members
     A comma seperated array of members
    .OUTPUTS
     Adds the users to all groups with the permissions level given for the supplied list
    .EXAMPLE 
     Add-HUSPMemberToGroups -url $mySPWeb.Url -list "Academic Conduct" -level "UF Review and Delete" -members ("spuftest3","John Wyman") -WhatIf
#>
    
function Add-HUSPMemberToGroups {

    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$level,
        [Parameter(Mandatory=$True,Position=4)]
        [string[]]$members
        )

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

    $SPTarget = $SPList.RoleAssignments | Where-Object { $_.RoleDefinitionBindings.Name -eq $level } 

    If ( $SPTarget -ne $null ) {
        ForEach ($SPRoleAssignment in $SPTarget ) {
            $SPGroupName = $SPRoleAssignment.Member
            ForEach ($member in $members) {
                try {
                    $SPWeb.EnsureUser($member)
                    $SPClaimsUser = $SPWeb.EnsureUser($member) | Select -ExpandProperty UserLogin
                    # Get the AD Group/User in a format that PowerShell can use otherwise there will be a string error
                    $ADMemberSPFriendly = $SPWeb | Get-SPUser $SPClaimsUser
                    #Add the AD Group/User to the group, can’t be done during group creation when using Powershell otherwise errors so is done now.
                    # Test if user already exists in group!
                    $SPUserTest = $SPWeb.SiteUsers | Where-Object { $_.LoginName -eq $ADMemberSPFriendly }
                    $SPUserGroupsTest = $SPUserTest.Groups | Where-Object { $_.Name -eq $SPGroupName }
                    If ( $SPUserGroupsTest -eq $null ) {
                        Write-Verbose "Adding $member validated as $SPClaimsUser to $SPGroupName"
                        If ($PSCmdlet.ShouldProcess($SPGroupName,"Adding $ADMemberSPFriendly")) {
                            Write-Host "Do not use this without checking for erroneous Registry group additions!"
                            # Set-SPUser -Identity $ADMemberSPFriendly -Web $SPWeb -Group $SPGroupName
                        }
                    } else {
                        Write-Host "$ADMemberSPFriendly is already a member of group $SPGroupName"
                    }
                } catch [Exception]{
                    Write-Error $_.Exception | format-list -force
                }
            }
        }
    } else {
        Write-Host "List $list does not have any $level permissions groups"
    }
    
    $SPWeb.Dispose()

}