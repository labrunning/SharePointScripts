<# 
    .Synopsis
     Applies Metadata to a field based on the source
    .DESCRIPTION
     Applies metadata to files from a given source, including files declared as records
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

function Set-HUSPDocumentMetadataMulti {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=6)]
        [string]$field
    )
    
    #Get destination site and list
    $SPSite = Get-SPSite $SPWeb.Site 
    $SPWeb = Get-SPWeb $url
    $SPWeb.AllowUnsafeUpdates = $true # Allows overwriting of records
    
    $SPList = $SPWeb.Lists[$list]
    $SPListItems = $SPList.Items

    $SPField = $SPSite.RootWeb.Fields.GetField($field)
    $SPFieldValueType = $SPField.TypeDisplayName

    Switch ($SPFieldValueType) {
        "Calculated" {"Calculated"}
        "Choice" {"Choice"}
        "Computed" {"Computed"}
        "Counter" {"Counter"}
        "Date and Time" {"Date and Time" ; Set-HUSPDate }
        "Hyperlink or Picture" {"Hyperlink or Picture"}
        "Lookup" {"Lookup"}
        "Managed Metadata" {"Managed Metadata"}
        "Multiple lines of text" {"Multiple lines of text"}
        "Person or Group" {"Person or Group"}
        "Single line of text" {"Single line of text"}
        "Yes/No" {"Yes/No"}
        default {"Unknown SPField Value"}
    }

    <#
        What next? Depending on the type we will get a value and possibly employ different methods to apply that data.
    #>

<#

    # Create valid metadata object to apply to document
    $destinationField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$SPList.Fields[$field]
    [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($destinationField)    
    $taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($destinationName) + "|" + $termValueGuid) 
        

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
        }
    }
    
#>    
    $SPWeb.AllowUnsafeUpdates = $false # Disallows overwriting of records
    $SPWeb.Dispose()
    $SPSite.Dispose()

}

function Set-HUSPDate {
    Write-Output "Setting date..."
}

function Get-HUSPMetadataValue {
        
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=3)]
        [string]$group,
        [Parameter(Mandatory=$True,Position=4)]
        [string]$set,
        [Parameter(Mandatory=$True,Position=5)]
        [string]$label
    )  

    $SPSite = Get-SPSite $SPWeb.Site
    
    $TaxonomySession = Get-SPTaxonomySession -Site $SPSite.Url 
    $TaxonomyField = $SPSite.RootWeb.Fields.GetField($field)    
    
    $TermStoreID = $TaxonomyField.SspId  
    $TermStore = $TaxonomySession.TermStores[$TermStoreID]
    
    $TermSetID = $TaxonomyField.TermSetId    
    $TermSet = $TermStore.GetTermSet($TermSetID) 
    
    $Term =  $TermSet.GetTerms($label, $true)
    
    return [string] $Term[0].Name +"|"+$Term[0].Id   
    
    $SPSite.Dispose()

}