<# 
    .Synopsis
     Adds fields to the metanavigation
    .DESCRIPTION
     Adds the fields specified on a paramater to the managed metadata navigation for a list
    .Parameter url
      A valid SharePoint Site url
    .Parameter list
      A valid SharePoint document library name
    .Parameter fields
      A list of managed metadata fields
    .OUTPUTS
      Adds the managed metadata fields to the document library navigation
    .EXAMPLE 
      Set-HUSPMetadataNavigation -url https://unishare.hud.ac.uk/unifunctions -list "Senior Management Team" -fields ("Committee Document Type")
#>

function Set-HUSPMetadataNavigation {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string[]]$fields
    )
    
    #Get Web and List objects
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

    #Get metadata navigation settings for the list
    $listNavSettings = [Microsoft.Office.DocumentManagement.MetadataNavigation.MetadataNavigationSettings]::GetMetadataNavigationSettings($SPList)

    #Clear current metadata navigation settings on the list
    #CHECKME ; should we always do this?
    $listNavSettings.ClearConfiguredHierarchies()
    $listNavSettings.ClearConfiguredKeyFilters()

    #Configure key filters by adding columns
    foreach ($field in $fields) {
        Write-Verbose -message "Setting $field navigation for $SPList"
        $listNavSettings.AddConfiguredHierarchy($SPList.Fields[$field])
    }

    #Add folder navigation hierarchies into list settings
    #This is required to enable and show navigation hierarchies in the Tree View
    $folderHierarchy = [Microsoft.Office.DocumentManagement.MetadataNavigation.MetadataNavigationHierarchy]::CreateFolderHierarchy()
    $listnavSettings.AddConfiguredHierarchy($folderHierarchy)
    
    #Set the new metadata navigation settings and update the root folder of the list
    [Microsoft.Office.DocumentManagement.MetadataNavigation.MetadataNavigationSettings]::SetMetadataNavigationSettings($SPList, $listNavSettings, $true)
    $SPList.RootFolder.Update()

    #Enable Tree View on the site so that navigation hierarchies can be used in the UI
    if ($SPWeb.TreeViewEnabled -eq $false) {
      Write-Verbose -Message "Tree view is not on, setting this now..."
      $SPWeb.TreeViewEnabled = $true
      $SPWeb.Update()
    }

    #Dispose of the Web object
    $SPWeb.Dispose()
}    