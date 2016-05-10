<#
    .Synopsis
    Shows the permissions inheritance for all webs in a site collection
    .DESCRIPTION
     This script will output whether each web in a site collection inherits the permissions from the site above it, or whether it has its own unique permissions
    .Parameter site
     Takes a valid site collection URL
    .OUTPUTS
     On screen message of whether it has unique permissions or inherits them
    .EXAMPLE 
     Get-HUSPSiteCollectionPermissionsIneritance -site https://unishare.hud.ac.uk/uniwide
     Outputs to the screen which webs in the site collection have inheritance or unique permission
#>  

function Get-HUSPSiteCollectionPermissionsIneritance {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$site
    )
  
    $SPSite = Get-SPSite $site 
  
    ForEach($SPWeb in $SPSite.AllWebs) { 
        If ($SPWeb.HasUniqueRoleAssignments) {
            Write-Host $SPWeb.Url "has unique permissions"
        } Else {
            Write-Host "** " $SPWeb.Url "inherits its permissions **"
        }
        $SPWeb.Dispose()
    }
    $SPSite.Dispose()
}