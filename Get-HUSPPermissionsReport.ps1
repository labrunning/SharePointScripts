<#
    .SYNOPSIS
    Gives a report on a user's permissions throughout a site
    .DESCRIPTION
    Traverses a whole SharePoint farm and looks for the permissions given to a user directly 
    .PARAMETER url
    a valid SharePoint site url
    .PARAMETER recursive
    boolean value for $true or $false for whether the report should travel recursively through the site
    .EXAMPLE
    An example of how the script can be used
    .NOTES
    Some notes about the script
    .LINK
    a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$recursive
)

function Get-HUSPPermissionsReport {
    Get-SPWeb $url | Get-SPUser -Limit ALL | % {
        New-Object PSObject -Property @{
            UserLogin = $_.UserLogin
            'Roles given explicitly' = $_.Roles
            'Roles given via groups' = $_.Groups | %{$_.Roles}
            Groups = $_.Groups
            Url = $web.Url
        }
    }

    if($recursive) {
        $web.Webs | % {
            Get-SPPermissionsReport $_ $recursive
        }
    }
}