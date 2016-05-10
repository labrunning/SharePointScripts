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
    $web = Get-SPWeb $url
    $listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list))
    $docLib = $web.Lists[$list]
    
    $web.AllowUnsafeUpdates = $true

    $query = New-Object Microsoft.SharePoint.SPQuery
    $query.ViewAttributes = "Scope='Recursive'"
    $query.RowLimit = 2000
    $caml = '<FieldRef Name="_dlc_DocId" /><FieldRef Name="Document Description" /><FieldRef Name="Title" /><FieldRef Name="FileLeafRef" /><FieldRef Name="BaseName" /><FieldRef Name="Committee Document Type" />' 
    $query.Query = $caml 

    do 
    {
        $listItems = $docLib.GetItems($query)
        $query.ListItemCollectionPosition = $listItems.ListItemCollectionPosition
        
        foreach($item in $listItems)
        {
            $CurrentRecord = $item['_dlc_DocId'].ToString()
            Write-Verbose -message "Checking $CurrentRecord"
            $ModifyDocumentType = {
                $CurrentTime = Get-Date -format yyyy-MM-dd_hh:mm
                $myCheckString = $CurrentTime
                $item['Document Description'] = $myCheckString
                $MyTitle = $item['BaseName']
                # do change
                If ($MyTitle -match "agenda") {
                    Write-Verbose -message "$CurrentRecord looks like an agenda as at $CurrentTime"
                    $item['Committee Document Type'] = "Agenda"
                }
                ElseIf ($MyTitle -match "-A_") {
                    Write-Verbose -message "$CurrentRecord looks like an agenda as at $CurrentTime"
                    $item['Committee Document Type'] = "Agenda"
                }
                ElseIf ($MyTitle -match "_A_") {
                    Write-Verbose -message "$CurrentRecord looks like an agenda as at $CurrentTime"
                    $item['Committee Document Type'] = "Agenda"
                }
                ElseIf ($MyTitle -match "minutes") {
                    Write-Verbose -message "$CurrentRecord looks like minutes as at $CurrentTime"
                    $item['Committee Document Type'] = "Minutes"
                }
                ElseIf ($MyTitle -match "-M_") {
                    Write-Verbose -message "$CurrentRecord looks like minutes as at $CurrentTime"
                    $item['Committee Document Type'] = "Minutes"
                }
                ElseIf ($MyTitle -match "_M_") {
                    Write-Verbose -message "$CurrentRecord looks like minutes as at $CurrentTime"
                    $item['Committee Document Type'] = "Minutes"
                }
                # ElseIf ($MyTitle -match "liaison notes") {
                #     Write-Verbose -message "$CurrentRecord looks like minutes as at $CurrentTime"
                #     $item['Committee Document Type'] = "Minutes"
                # }
                Else {
                    Write-Verbose -message "$CurrentRecord looks like a paper as at $CurrentTime"
                    $item['Committee Document Type'] = "Paper"
                }

                $item.SystemUpdate($false)
            }
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($item, $ModifyDocumentType)
        }
    }
    while ($query.ListItemCollectionPosition -ne $null)
    
    $web.AllowUnsafeUpdates = $false
    $web.Dispose()
}