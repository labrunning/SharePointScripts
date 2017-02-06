 <#     
    .Synopsis
     A brief outline of what the script does
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter web
      The Web Application
    .Parameter list
      The list to act on
    .OUTPUTS
      This is a description of what the script outputs
    .EXAMPLE 
      My-Script -web -list
      Does what the script does
    .LINK
      A link (usually a link to where I stoled the script from)
#>

function Get-HUSPAllWebAppSiteOwners {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url
    )

    $SPWebApplication = Get-SPWebApplication -Identity $url

    ForEach ($SPSiteCollection in $SPWebApplication.Sites) {
        $SPSiteCollectionValues = @{
            "Title" =  $SPSiteCollection.RootWeb.Title
            "Url" = $SPSiteCollection.Url
            "Admins" = $SPSiteCollection.SiteAdministrators
        }
        New-Object PSOBject -Property $SPSiteCollectionValues | Select @("Title","Url","Admins")
    }

}