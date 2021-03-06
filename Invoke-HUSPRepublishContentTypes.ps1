<#
    .SYNOPSIS
    Republishes all Published Content Types from the specified Content Type Hub
    .DESCRIPTION
    This script republishes all published content types from the specified content type hub Url. Content Types which have not been published will not be affected.
    .PARAMETER CTHubURL
    a valid content type hub url
    .EXAMPLE
    Invoke-HUSPRepublishContentTypes -CTHubURL 'https://devunishare.hud.ac.uk/sites/ct'
#>

function Invoke-HUSPRepublishContentTypes {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=1)]
        [string]$CTHubURL="https://unifunctions.hud.ac.uk/ct"
    )
        
    $ctHubSite = Get-SPSite $CTHubURL
    $ctHubWeb = $ctHubSite.RootWeb

    if ([Microsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher]::IsContentTypeSharingEnabled($ctHubSite)) {
        $spCTPublish = New-Object Microsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher ($ctHubSite)
        $ctHubWeb.ContentTypes | Sort-Object Name | ForEach-Object {
            $CurrentContentType = $_.Name
            if ($spCTPublish.IsPublished($_)) {
                $spCTPublish.Publish($_)
                Write-Host "*** Content type $CurrentContentType has been republished ***" -foregroundcolor Green
            } else { 
                Write-Verbose -message "Content type $CurrentContentType is not a published content type"
            }
        }
    } else { Write-Output "$CTHubURL is not a content type hub site" -foregroundcolor Red }
    $ctHubWeb.Dispose()
    $ctHubSite.Dispose()
}