<#
    .Synopsis
     Sets the logo on sites
    .DESCRIPTION
     Sets the logo on all sites in a site collection. The logo must first be loaded into a document library in SharePoint accessible by all sites in a site collection
    .Parameter url
      A valid SharePoint Site Collection URL
    .Parameter logo
      A valid URL of an image file
    .OUTPUTS
      All sites will now have the logo specified
    .EXAMPLE 
      Set-HUSPLogo -url https://unishare.hud.ac.uk/unifunctions/SiteAssets/Unifunctions_logo.png -url https://unishare.hud.ac.uk/unifunctions
      Sets the logo in all the sites in the site collection
    .LINK
      I don't recall where I stole this from
#>

function Set-HUSPLogo {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$logo
    )

    $sitelogo=$logo
    $SiteCollection=$url
    # $Sites=Get-SPWebApplication $Site | Get-SPSite -Limit All | Get-SPWeb -Limit All | Select URL <- this can be used for a whole web app
    $Sites=Get-SPSite $SiteCollection | Get-SPWeb -Limit All | Select URL
    $Sites | ForEach-Object {
        $CurrentSite=$_.URL
        $CurrentSiteObject=new-object Microsoft.SharePoint.SPSite($CurrentSite)
        foreach($web in $CurrentSiteObject.Allwebs) {
            $web.SiteLogoUrl=$sitelogo
            $web.Update()
        }
        $CurrentSiteObject.Dispose()
    }
}