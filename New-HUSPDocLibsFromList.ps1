<#
    .SYNOPSIS
    Creates a number of document libraries from a CSV list
    .DESCRIPTION
    This script will create a number of document libraries from a valid CSV file which contains the titles and descriptions for each of the document libraries. There must be a title for each document library but there does not need to be a description. The content types must be seperated with a semi-colon.
    EXAMPLE
    -------
    Title,Description,ContentType
    "University Health and Safety Committee","","UF University Committee"
    .PARAMETER url
    a valid SharePoint Site Url
    .PARAMETER csv
    a valid CSV file
    .EXAMPLE
    New-HUSPDocumentLibraries -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -csv .\DocLibList.csv
#>
function New-HUSPDocLibsFromList {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$csv
    )
    
    $docList = Import-Csv -Path "$csv"
    $libList = $docList

    $listTemplate = [Microsoft.SharePoint.SPListTemplateType]::DocumentLibrary 
    
    $SPWeb = Get-SPWeb $url
  
    Write-Host "You are about to create the following Document Libraries;"
    $libList
    $confirmation = Read-Host "Are you sure you want to proceeed? (press 'y' to proceed)"
        
    # Loop through all the document libraries in the list
    If ($confirmation -eq 'y') {
        ForEach ($docLib in $libList) {
            Write-Verbose "Creating Document Library $listname..."
            $listname = $docLib.Title
            $SPWeb.Lists.Add($listname,$docLib.Description,$listTemplate)
            $CurrentList = $SPWeb.Lists[$listname]
            
            # Change List Settings
            Write-Verbose "Disabling Folder Creation"
            $CurrentList.EnableFolderCreation = $false
            Write-Verbose "Disabling Content Approval"
            $CurrentList.EnableModeration = $false
            Write-Verbose "Enabling Version Control"
            $CurrentList.EnableVersioning = $true
            Write-Verbose "Enabling Minor Versions"
            $CurrentList.EnableMinorVersions = $true
            Write-Verbose "Disabling Force Check Out"
            $CurrentList.ForceCheckout = $false
            Write-Verbose "Enabling Content Types"
            $CurrentList.ContentTypesEnabled = $true
            $ContentTypeToApply = $docLib.ContentType
            # Apply Content Types
            $SPSiteName = $SPWeb.Site 
            $SPSiteUrl = $SPSiteName.Url
            $SPSite = Get-SPSite $SPSiteUrl
            Write-Verbose -message "Applying content type $ContentTypeToApply"
            $ContentTypeToAdd = $SPSite.RootWeb.ContentTypes[$ContentTypeToApply]
            $CurrentList.ContentTypes.Add($ContentTypeToAdd)
            # Get the current default content type
            $DefaultContentType = $CurrentList.ContentTypes["Document"]
            # Remove the previous default content type
            $CurrentList.ContentTypes.Delete($DefaultContentType.Id)
            $SPSite.Dispose()
            $CurrentList.Update()
        }
    }
    
    $SPWeb.Dispose()

}