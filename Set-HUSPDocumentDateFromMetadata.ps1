<# 
    .Synopsis
     Applies metadata from the WISDOM archived metadata field to a field in the list
    .DESCRIPTION
     For a given list this script will apply a metadata value to every item in this list based on the list name. This can be used to apply metadata not brought over in the migration; the field the contains the metadata MUST have a corresponding entry in the term set with all the values required in for this script to work.
    .Parameter url
      A valid SharePoint list url
    .Parameter list
      A valid SharePoint list name
    .Parameter xmlfield
      A valid SharePoint WISDOM Archived Metadata field
    .Parameter field
      A valid SharePoint Field
    .OUTPUTS
      All the documents in the list will have the metadata term applied
    .EXAMPLE 
      Set-HUSPDocumentMetadataFromArchivedMetadata -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee" -group "UF Fileplan" -set "Committees" -field "University Committee Name"
#>

function Set-HUSPDocumentDateFromMetadata {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$false,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$false,Position=3)]
        [string]$xpath,
        [Parameter(Mandatory=$false,Position=5)]
        [string]$field="Committee Date"
    )
    
    #Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPListItems = $SPList.Items

    $SPWeb.AllowUnsafeUpdates = $true
    
    # Iterate over relevant items
    # **ONLY WRITE OVER EMPTY FIELDS!!**    
    foreach($item in $SPListItems | where {$_[$field] -eq $null} ) {
        $CurrentRecordId = $item['_dlc_DocId'].ToString()
        $CurrentName = $item['Name'].ToString()

        [xml]$archivedMetadataXML = $item["Archived Metadata"].ToString()
        $myDateOfOrigin = Get-Date $archivedMetadataXML.DocumentDataSet.Wis_Document_Detailed.DateOfOrigin
        
        Write-Verbose -message "Date of Origin for $CurrentRecordId is $myDateOfOrigin"
        Write-Verbose -message "Filename is $CurrentName"        
        
        If ($CurrentName -match "[ -_]\d{1,2}[a-z]{3,4}?\d{2}?[ -_]") {
            Write-Verbose -message "$CurrentName looks like it has a date in it; $matches[0]"
        }

        $RecordsManagement = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]
        $IsRecord = $RecordsManagement::IsRecord($item)
        if ($IsRecord -eq $true) {
                    Write-Verbose -message "  $CurrentRecordId is RECORD; $field will be updated to $myDateOfOrigin"
                    $ModifyRecord = {
                        $item[$field] = $myDateOfOrigin
                        $item.SystemUpdate($false)
                    }
                    # [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($item, $ModifyRecord)
        } else {
                    Write-Verbose -message "  $CurrentRecordId $field will be updated to $myDateOfOrigin"
                    $ModifyRecord = {
                        $item[$field] = $myDateOfOrigin
                        $item.SystemUpdate($false)
                    }
                    # [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($item, $ModifyRecord)
        }
        
    }
    $SPWeb.AllowUnsafeUpdates = $false
    $SPWeb.Dispose()
}