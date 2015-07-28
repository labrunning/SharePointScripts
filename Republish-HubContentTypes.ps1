<#
.SYNOPSIS
Republishes all Published Content Types from the specified Content Type Hub
.DESCRIPTION
This script republishes all published content types from the specified content type hub Url. Content Types which have not been published will not be affected.
.PARAMETER CTHubURL
a valid content type hub url
.EXAMPLE
Republish-HubContentTypes -CTHubURL 'https://devunishare.hud.ac.uk/sites/ct'
#>
function Republish-HubContentTypes ($CTHubURL)
{
    #Get Content Type site and web objects
    $ctHubSite = Get-SPSite $CTHubURL
    $ctHubWeb = $ctHubSite.RootWeb

    #Check the site is a content type hub
    if ([Microsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher]::IsContentTypeSharingEnabled($ctHubSite))
    {
        #Set up ContentTypePublisher object to allow publishing through the Content Type Hub site
        $spCTPublish = New-Object Microsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher ($ctHubSite)
        
        #Step through each content type in the content type hub
        $ctHubWeb.ContentTypes | Sort-Object Name | ForEach-Object {
            
            #Has the content type been published?
            if ($spCTPublish.IsPublished($_))
            {
                #Republish content type
                $spCTPublish.Publish($_)
                write-host "Content type" $_.Name "has been republished" -foregroundcolor Green
            }
            else
            {
                write-host "Content type" $_.Name "is not a published content type"
            }
        }
    }
    else
    {
        write-host $CTHubURL "is not a content type hub site"
    }
    #Dispose of site and web objects
    $ctHubWeb.Dispose()
    $ctHubSite.Dispose()
}
