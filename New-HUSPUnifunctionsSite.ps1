<#
    .Synopsis
     A brief outline of what the script does
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter url
      A new valid SharePoint url which must be inside a site collection
    .Parameter name
      A valid SharePoint name for the site
    .Parameter description
      A description for the site
    .OUTPUTS
      This is a description of what the script outputs
    .EXAMPLE 
      My-Script -web -list
      Does what the script does
    .LINK
      A link (usually a link to where I stoled the script from)
#>

function New-HUSPUnifunctionSite {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$name,
        [Parameter(Mandatory=$false,Position=3)]
        [string]$description
    )

    # create the site
    Write-Verbose "Creating $SiteURL..."
    New-SPWeb -Url $url -Name $name -Description $description -Template "BDR#0" -UniquePermissions -UseParentTopNav | Out-Null
    
    # apply the site settings
    $SPWeb = Get-SPWeb $url
    $SPWeb.allowunsafeupdates = $true
    Write-Verbose -Message 'Set the locale to en-UK'
    $culture=[System.Globalization.CultureInfo]::CreateSpecificCulture("en-UK") 
    $SPWeb.Locale=$culture 
    Write-Verbose -Message 'Enabling Tree View...'
    $SPWeb.TreeViewEnabled = $true
    Write-Verbose -Message 'Disabling Quick Launch...'
    $SPWeb.QuickLaunchEnabled = $false
    
    # Site logo
    $SiteCollectionUrl = $SPWeb.Site.Url
    $SiteLogoUrl = [Microsoft.SharePoint.Utilities.SPUrlUtility]::CombineUrl($SiteCollectionUrl, "/SiteAssets/Unifunctions_Logo.png")
    $SPWeb.SiteLogoUrl=$SiteLogoUrl
    $SPWeb.Update()

    # Content Organizer
    Enable-SPFeature -Identity "DocumentRouting" -URL $SPWeb.url | Out-Null
    $SPDropOffLib = $SPWeb.Lists["Drop Off Library"]
    $SPDropOffLib.Title = "@Drop Off Library"
    $SPDropOffLib.Update()
    
    # Disabling Features
    Disable-SPFeature -Identity "FollowingContent" -URL $SPWeb.url -Force | Out-Null
    Disable-SPFeature -Identity "MBrowserRedirect" -URL $SPWeb.url -Force | Out-Null

    # Remove the default document libraries created
    foreach ($DefaultLibrary in "Documents","Tasks") {
        $LibraryToDelete = $SPWeb.Lists[$DefaultLibrary]
        $LibraryToDelete.Delete()
    }           

    <#
        @(TODO) - add retention to the audit log folder
        one year retention on audt logs
        agreed at meeting on 2016-03-21 between Rebecca McCall, Sarah Wickham, Sarah Gullick and Luke Brunning
    #>
    
    # Create a audit log document library for the site
    $listTemplate = [Microsoft.SharePoint.SPListTemplateType]::DocumentLibrary
    $SPWeb.Lists.Add("@Audit Reports","A place to save audit log reports.",$listTemplate)
    
    $SPWeb.allowunsafeupdates = $false

    # apply all settings
    $SPWeb.Update()
    Write-Verbose -Message "Created site $SPWeb"
    Write-Output "Site GUID is " $SPWeb.ID
    $SPWeb.Dispose()

}    