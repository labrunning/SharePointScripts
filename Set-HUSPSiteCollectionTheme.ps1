<#
    ################################################################
    .Synopsis
     Sets the theme for all webs in a site collection
    .DESCRIPTION
     Sets the logo and colour palette for all sub-sites in a site collection
    .Parameter url
     A valid SharePoint Site Collection URL
    .Parameter theme
     A name for the theme (this must be the name of a theme listed in the site collection themes
    .OUTPUTS
     Sets the logo and theme for all the sub-sites in the site collection
    .EXAMPLE 
     Set-HUSPSiteCollectionTheme -url 
    ################################################################
#>
    

function Set-HUSPSiteCollectionTheme {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$theme
    )
        
    $themeName = $theme
    $SPSite = Get-SPSite $url    
    foreach ($SPWeb in $SPSite.AllWebs) 
    {
        $SPWeb.allowunsafeupdates = $true
        $fontSchemeUrl = Out-Null
        $themeUrl = [Microsoft.SharePoint.Utilities.SPUrlUtility]::CombineUrl($SPSite.ServerRelativeUrl, "/_catalogs/theme/15/" + $theme + ".spcolor")
        $imageUrl = Out-Null
        $SPWeb.ApplyTheme($themeUrl, $fontSchemeUrl, $imageUrl, $true);
        Write-Output $SPWeb.Title
        $SPWeb.allowunsafeupdates = $false
        $SPWeb.Dispose()
    }  
    $SPSite.Dispose()

}