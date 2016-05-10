<#
    .SYNOPSIS
    Gets the GUID of a site collection and its lists
    .DESCRIPTION
    Outputs a site collection's GUID, the subsite GUID (if specified) and all the GUIDs of lists in the web/site
    .PARAMETER site
    a valid SharePoint Site Collection URL
    .PARAMETER web
    a valid SharePoint web url
    .EXAMPLE
    Get-HUSPSiteGUIDs -site https://unishare.hud.ac.uk/unifunctions -web COM/University-Committees
#>

function Get-HUSPSiteGUIDs {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$site,
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [string]$web
    )
    
    $SPSite = Get-SPSite $site
    $SPWeb = $SPSite.OpenWeb($web)
    write-host "Site: " + $SPSite.id
    write-host "Web: " + $SPWeb.id
    $SPWeb.lists | Format-Table title,id -AutoSize
    $SPWeb.Dispose()
    $SPSite.Dispose()
}