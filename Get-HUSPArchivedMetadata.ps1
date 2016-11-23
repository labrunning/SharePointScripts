<#
    ################################################################
    .Synopsis
     Gets the Archived Metadata from documents imported from WISDOM
    .DESCRIPTION
     Gets the XML Archived Metadata from WISDOM which is stored with each document and saves it to the audit log folder in each web for a specified document
    .Parameter url
     A valid SharePoint Web Site Url
    .Parameter list
     A valid SharePoint List name
    .Parameter id
     A valid document ID integer
    .OUTPUTS
     An XML file in the audit reports folder containing the XML data from the Archived Metadata field
    .EXAMPLE 
     Get-HUSPArchivedMetadata -url https://testunifunctions.hud.ac.uk/COM/University-Committees -list "University Health and Safety Committee" -id 173
    ################################################################
#>
    
function Get-HUSPArchivedMetadata {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$id
    )
        
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPItem = $SPList.GetItemById($id)
    $SPArchivedMetadata = $SPItem["Archived Metadata"].ToString()

    # Save the XML string to a file in Audit Reports
    $SPXmlFileName = ".\SPLogs\" +$SPItem["Document ID Value"] + ".xml"
    $SPSiteUrl = $SPWeb.Url
    $SPSiteAuditFolder = "@Audit Reports"
    
    Add-Content $SPXmlFileName $SPArchivedMetadata

    $SPXmlFile = Get-Item $SPXmlFileName
    $SPStream = $SPXmlFile.OpenRead() 
    $SPUploadList = $SPWeb.Lists[$SPSiteAuditFolder]
    $SPFileCollection = $SPUploadList.RootFolder.Files
    Write-Verbose $SPXmlFile.Name
    $SPFileCollection.Add($SPXmlFile.Name,$SPStream,$true)
    $SPStream.Close()
    $SPXmlFile.Delete()

    $SPWeb.Dispose()

}