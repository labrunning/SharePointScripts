<# 
    .Synopsis
     Applies Committee metadata value to a field based on the list name
    .DESCRIPTION
     For a given list this script will apply a metadata value to every item in this list based on the list name. This can be used to apply metadata not brought over in the migration; the field the contains the metadata MUST have a corresponding entry in the term set with all the values required in for this script to work.
    .Parameter url
      A valid SharePoint list url
    .Parameter list
      A valid SharePoint list name
    .Parameter group
      A valid SharePoint Metadata Term Set Group
    .Parameter set
      A valid SharePoint Metadata Term Set
    .Parameter field
      A valid SharePoint Field
    .OUTPUTS
      All the documents in the list will have the metadata term applied
    .EXAMPLE 
      Set-HUSPDocumentMetadata -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee" -group "UF Fileplan" -set "Committees" -field "University Committee Name"
#>

function Set-HUSPDocumentMetadata {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$false,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$false,Position=3)]
        [string]$group,
        [Parameter(Mandatory=$false,Position=4)]
        [string]$set,
        [Parameter(Mandatory=$false,Position=5)]
        [string]$field
    )
    
    #Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPListItems = $SPList.Items
    $docLib = $SPWeb.Lists[$list]

    $SPWeb.AllowUnsafeUpdates = $true
    
    # Get the Term ID for the metadata
    $committeeName = $SPList
    $ts = Get-SPTaxonomySession -Site $SPWeb.Site 
    $tstore = $ts.TermStores[0] 
    $tgroup = $tstore.Groups[$Group] 
    $tset = $tgroup.TermSets[$Set] 
    $term =  $tset.GetTerms($committeeName,$true) | Where { $_.Parent.Name -eq $field }
    $termValueGuid = $term.Id

    # Create valid metadata object to apply to document
    $committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$docLib.Fields[$field]
    [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
    $taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + "|" + $termValueGuid) 
        
    foreach($item in $SPListItems | where {$_[$field] -eq $null} ) {
        $CurrentRecord = $item['_dlc_DocId'].ToString()
        Write-Verbose -message "Checking $CurrentRecord"
        $RecordsManagement = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]
        $IsRecord = $RecordsManagement::IsRecord($item)
        if ($IsRecord -eq $true) {
                    Write-Verbose -message "  $CurrentRecord is RECORD; $field will be updated to $taxonomyFieldValue"
                    $ModifyRecord = {
                        $item[$field] = $taxonomyFieldValue.ValidatedString
                        $item.SystemUpdate($false)
                    }
                    [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($item, $ModifyRecord)
        } else {
                    Write-Verbose -message "  $CurrentRecord $field will be updated to $taxonomyFieldValue"
                    $ModifyRecord = {
                        $item[$field] = $taxonomyFieldValue.ValidatedString
                        $item.SystemUpdate($false)
                    }
                    [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($item, $ModifyRecord)
                    <#$item[$field] = $taxonomyFieldValue.ValidatedString
                    $item.SystemUpdate($false)#>
        }
    }
    
    $SPWeb.AllowUnsafeUpdates = $false
    $SPWeb.Dispose()
}