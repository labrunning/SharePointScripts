<#
    .SYNOPSIS
    Creates a number of document libraries from a CSV list
    .DESCRIPTION
    This script will create a number of document libraries from a valid CSV file which contains the titles and descriptions for each of the document libraries. There must be a title for each document library but there does not need to be a description. The content types must be seperated with a semi-colon.
    
    EXAMPLE
    -------
    Title,Description,ContentTypes
    "University Health and Safety Committee","","EDRMS University Committee;EDRMS Email"
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
  
    Write-Verbose "You are about to create the following Document Libraries;"
    $libList
    $confirmation = Read-Host "Are you sure you want to proceeed? (press 'y' to proceed)"
        
    # Loop through all the document libraries in the list
    If ($confirmation -eq 'y') {
        ForEach ($docLib in $libList) {
            $listname = $docLib.Title
            Write-Verbose "Creating Document Library $listname..."
            $SPWeb.Lists.Add($listname,$docLib.Description,$listTemplate)
            $CurrentList = $SPWeb.Lists[$listname]
            Write-Verbose "Be Ye Disabling Yon Folder Creation"
            $CurrentList.EnableFolderCreation = $false
            Write-Verbose "Be Ye Disabling Yon Content Approval"
            $CurrentList.EnableModeration = $false
            Write-Verbose "Be Ye Enabling Yon Version Control"
            $CurrentList.EnableVersioning = $true
            Write-Verbose "Be Ye Enabling Yon Minor Versions"
            $CurrentList.EnableMinorVersions = $true
            Write-Verbose "Be Ye Disabling Yon Force Check Out"
            $CurrentList.ForceCheckout = $false
            Write-Verbose "Be Ye Enabling Yon Content Types"
            $CurrentList.ContentTypesEnabled = $true
            $CurrentList.Update()
            $ContentTypesToApply = $docLib.ContentTypes
            $ContentTypeArray = $ContentTypesToApply.Split(";")
            ForEach ($ContentType in $ContentTypeArray) {
                Write-Verbose "Adding '$ContentType' Content Type to Document Library $CurrentList..."
                $ContentTypeToAdd = $SPWeb.RootWeb.ContentTypes[$ContentType]
                $AddContentType = $CurrentList.ContentTypes.Add($ContentTypeToAdd)
            }
        }
        $SPWeb.Dispose()
    }
}