<# 
    .Synopsis
     Changes the document type of a committee document depending on the information in the file
    .DESCRIPTION
     For a given list this script will apply a document type according to metadata in the file, for example if Agenda is found in the tile, apply the Agenda document type
    .Parameter url
     A valid SharePoint list url
    .Parameter list
     A valid SharePoint list name
    .OUTPUTS
     All the documents in the list will have the metadata term applied
    .EXAMPLE 
     Set-HUSPComDocType -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee"
     Sets the Committee Document Type according to the values in the file name
#>

function Set-HUSPComDocType {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$false,Position=2)]
        [string]$list
    )
    
    # Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

    Write-Output Examining $SPList.Title 
    
    $SPWeb.AllowUnsafeUpdates = $true
    
    $query = New-Object Microsoft.SharePoint.SPQuery
    $query.ViewAttributes = "Scope='Recursive'"
    $caml = '<FieldRef Name="_dlc_DocId" /><FieldRef Name="Title" /><FieldRef Name="FileLeafRef" /><FieldRef Name="Committee Document Type" />' 
    $query.Query = $caml 

    do {
        $SPListItems = $SPList.GetItems($query)
        $query.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        
        foreach($SPItem in $SPListItems) {
            $CurrentRecord = $SPItem['_dlc_DocId'].ToString()
            $MyPrintTitle = $SPItem['FileLeafRef'].ToString()
            $ModifyDocumentType = {
                $MyTitle = $SPItem['FileLeafRef']
                # do change
                If ($MyTitle -imatch "^tor | tor |terms of ref") {
                    $DocumentType = "Terms of Reference"
                } ElseIf ($MyTitle -imatch "minutes|[\d _-]+?m(in)*?(inute)*?s*?[( _-]") {
                    $DocumentType = "Minutes"
                } ElseIf ($MyTitle -imatch "agenda|[^p\d\.?]?[_-]a(genda)*?[( _-]") {
                    $DocumentType = "Agenda"
                } Else {
                    $DocumentType = "Paper"
                }
                $SPItem['Committee Document Type'] = $DocumentType
                Write-Output "DocID|$CurrentRecord|Title|$MyPrintTitle|Document Type|$DocumentType" -ForegroundColor Green
                $SPItem.SystemUpdate($false)
            }
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($SPItem, $ModifyDocumentType)
        }
    }
    while ($query.ListItemCollectionPosition -ne $null)
    
    $SPWeb.AllowUnsafeUpdates = $false
    $SPWeb.Dispose()
}