<# 
    .Synopsis
     Sets the theme for all sites in a site collection
    .DESCRIPTION
     Sets the color, font scheme and background image of all sites in a site collection. The theme file must be uploaded to all the webfront end 15 hive folder location.
    .Parameter url
      The site collection URL
    .Parameter name
      The name of the theme (this is a required value but does not have any effect)
    .Parameter color
      The name of the SP Color file you want to apply
    .OUTPUTS
      Sets all sites in a site collection to a specific theme
    .EXAMPLE 
      Set-HUSPTheme -url https://devunishare.hud.ac.uk -name UoHDEVEDRMS -color Palette012
      Sets all sites in the site collection to the Palette012 colour scheme
    .LINK
      A link (usually a link to where I stoled the script from)
#>    

function Set-HUSPTheme {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$name,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$color
    )
        
    $themeName = $name
    $SPSite = Get-SPSite $url
    $spcolor = "/_catalogs/theme/15/" + $color + ".spcolor"
    foreach ($SPWeb in $SPSite.AllWebs ) {
        $SPWeb.allowunsafeupdates = $true
        Write-Verbose -message "Applying $color to $SPWeb.url"
        $fontSchemeUrl = Out-Null
        $themeUrl = [Microsoft.SharePoint.Utilities.SPUrlUtility]::CombineUrl($SPSite.ServerRelativeUrl, $spcolor)
        $imageUrl = Out-Null
        # add an if here to set to parameter if there is a value for image
        # $imageUrl = [Microsoft.SharePoint.Utilities.SPUrlUtility]::CombineUrl($SPSite.ServerRelativeUrl, "/images/Unifunctions_logo.png")
        $SPWeb.ApplyTheme($themeUrl, $fontSchemeUrl, $imageUrl, $true);
        write-host $SPWeb.Title " theme has been set to " $themeName
        $SPWeb.allowunsafeupdates = $false
        $SPWeb.Dispose()
    }  
    $SPSite.Dispose()
}