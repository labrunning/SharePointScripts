<#
    .SYNOPSIS
    A brief description of what the script does
    .DESCRIPTION
    A longer more detailed description of what the script does
    .PARAMETER param
    a description of a parameter
    .EXAMPLE
    An example of how the script can be used
    .NOTES
    Some notes about the script
    .LINK
    a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>
 
function Get-HUSPSiteGUIDs {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$SiteCollection,
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [string]$SubSite
    )
    
    $site = Get-SPSite $SiteCollection
    $web = $site.OpenWeb($Subsite)
    write-host "Site: " + $site.id
    write-host "Web: " + $web.id
    $web.lists | Format-Table title,id -AutoSize
    $web.Dispose()
    $site.Dispose()
}