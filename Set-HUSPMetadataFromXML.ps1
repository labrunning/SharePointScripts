<# 
    .SYNOPSIS
     Applies metadata from the WISDOM archived metadata XML to a field in the list
    .DESCRIPTION
     For a given list this script will apply a metadata value to every item in this list based on the list name which matches the supplied CAML query. This can be used to apply metadata not brought over in the migration; any managed metadata fields that are being written to MUST have a corresponding entry in the term set; unmatched values will not create a term set. You can test CAML queries with the Test-HUSPCamlQuery function.
    .PARAMETER url
      A valid SharePoint list url
    .PARAMETER list
      A valid SharePoint list name
    .PARAMETER xpath
      A valid XML path for the archived metadata field value
    .PARAMETER field
      A valid SharePoint field you want to write to
    .PARAMETER xml
      A valid path to an XML file with a CAML query for the items you want to use
    .PARAMETER write
      A flag to state whether you want to actually write the values
    .PARAMETER group
      A valid term store group for any managed metadata (defaults to "UF Fileplan")
    .PARAMETER set
      A valid term set for the terms you want to search in  
    .OUTPUTS
      All the documents in the list will have the metadata term applied
    .EXAMPLE 
      Set-HUSPMetadataFromXML -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee" -xpath "subjects" -field "School of Education and Professional Development Subject" -xml ".\scripts\xml\caml_nullsubjects.xml" -group "UF Fileplan" -set "Subjects"
#>

function Get-HUSPTaxonomyValue($value) {
    $SPTaxonomyValue = $value
    $SPTaxonomySession = Get-SPTaxonomySession -Site $SPWeb.Site
    $SPTermStore = $SPTaxonomySession.TermStores[0] 
    $SPTermStoreGroup = $SPTermStore.Groups[$group] 
    $SPTermSet = $SPTermStoreGroup.TermSets[$set] 
    # This is currently only going to work for the subjects due to the 'WHERE' function at the end
    try {    
        $SPTerm =  $SPTermSet.GetTerms($SPTaxonomyValue,$true) | Where { $_.Parent.Name -eq $SPWeb.Title }
        $SPTermValueGuid = $SPTerm.Id
        $SPTaxonomyField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$SPList.Fields[$field]
        [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$SPTaxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($SPTaxonomyField)    
        $SPTaxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($SPTaxonomyValue) + "|" + $SPTermValueGuid)
        $setFieldValue = $SPTaxonomyFieldValue.ValidatedString
        $RecordsManagement = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]
        $setFieldValue
        $ModifyRecord = {
            $SPItem[$field] = $setFieldValue
            $SPItem.SystemUpdate($false)
        }
        if ( $write -eq $true) {
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($SPItem, $ModifyRecord)
            Write-Host "A term string of $setFieldValue has been written to $field" -ForegroundColor Green            
        } else {
            Write-Host "A term string of $setFieldValue would have been written to $field" -ForegroundColor Yellow
        }
    } catch [Exception]{
        Write-Host "Could not find a matching term for: $SPTaxonomyValue" -foregroundcolor red
    }
}

function Get-HUSPDateTimeValue($value) {
    $myDateRegex = "([0-9]{1,2})(?:st|nd|rd|th)?[\. _-]?(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]{0,6}[\. _-]?([0-9]{2,4})"
    If ( $value -imatch $myDateRegex ) {
        $myDate = $matches[1] + "-" + $matches[2]+ "-" + $matches[3]
        try {
                $setFieldValue = Get-Date $myDate
                $ModifyRecord = {
                    $SPItem[$field] = $setFieldValue
                    $SPItem.SystemUpdate($false)
                }
                if ($write -eq $true) {
                    [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($SPItem, $ModifyRecord)
                    Write-Host "A date of $setFieldValue has been written to $field" -ForegroundColor Green
                } else {
                    Write-Host "A date of $setFieldValue would have been written to $field"  -ForegroundColor Yellow
                }
            } catch [Exception]{
                Write-Host "A valid date could not be created" -foregroundcolor red
        }
    } else {
        Write-Host "No valid date match was found" -foregroundcolor red
        $setFieldValue = $null
    }
}

function Set-HUSPMetadataFromXML {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [String]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [String]$list,
        [Parameter(Mandatory=$true,Position=3)]
        [String]$xpath,
        [Parameter(Mandatory=$true,Position=5)]
        [String]$field,
        [Parameter(Mandatory=$true,Position=6)]
        [String]$xml,
        [Parameter(Mandatory=$false,Position=6)]
        [Boolean]$write=$false,
        [Parameter(Mandatory=$false,Position=7)]
        [String]$group="UF Fileplan",
        [Parameter(Mandatory=$false,Position=8)]
        [String]$set
    )
    
    #Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPField = $SPList.Fields[$field]
    $SPFieldType = $SPField.TypeAsString
    
    $SPWeb.AllowUnsafeUpdates = $true
    
    $spQuery = New-Object Microsoft.SharePoint.SPQuery
    $caml = Get-Content $xml -Raw
    $spQuery.Query = $caml 

    do {
        $SPListItems = $SPList.GetItems($spQuery)
        $spQuery.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        foreach($SPItem in $SPListItems) {
            # Get current record information
            $SPItemId = $SPItem['_dlc_DocId'].ToString()
            $SPItemName = $SPItem['Name'].ToString()
            Write-Host "---+++Start Item $SPItemId+++---" -foregroundcolor cyan 
            # Get field value information
            try {
                [xml]$SPItemXML = $SPItem["Archived Metadata"].ToString()
                # Devise a method using XPath and Namespaces to get any value in the archived metadata
                $SPXmlNs = $SPItemXML.DocumentElement.NamespaceURI
                $ns = @{ns0=$SPXmlNs}
                $SPXmlNode = Select-Xml -Xml $SPItemXML -xpath "//ns0:$xpath" -Namespace $ns | Select-Object -ExpandProperty Node    
                Write-Host "Item Title:"$SPItem.Title -ForegroundColor White
                [String]$SPXmlValue = $SPXmlNode.'#text'    
            } catch [Exception]{
                    Write-Host "No Archived Metadata was returned" -foregroundcolor red
                    Write-Host $_.Exception | format-list -force
            }

            Switch ($SPFieldType) {
                "Boolean" {Write-Host "The field type is Boolean"}
                "Calculated" {Write-Host "The field type is Calculated"}
                "Choice" {Write-Host "The field type is Choice"}
                "Computed" {Write-Host "The field type is Computed"}
                "ContentTypeId" {Write-Host "The field type is ContentTypeId"}
                "Counter" {Write-Host "The field type is Counter"}
                "DateTime" {
                    Write-Verbose -Message "The field type is DateTime"
                    Get-HUSPDateTimeValue -value $SPXmlValue
                }
                "ExemptField" {Write-Host "The field type is ExemptField"}
                "File" {Write-Host "The field type is File"}
                "Guid" {Write-Host "The field type is Guid"}
                "Integer" {Write-Host "The field type is Integer"}
                "Lookup" {Write-Host "The field type is Lookup"}
                "LookupMulti" {Write-Host "The field type is LookupMulti"}
                "ModStat" {Write-Host "The field type is ModStat"}
                "Note" {Write-Host "The field type is Note"}
                "Number" {Write-Host "The field type is Number"}
                "TaxonomyFieldType" {
                    Write-Verbose -Message "The field type is TaxonomyFieldType"
                    Get-HUSPTaxonomyValue -value $SPXmlValue
                }
                "TaxonomyFieldTypeMulti" {Write-Host "The field type is TaxonomyFieldTypeMulti"}
                "Text" {Write-Host "The field type is Text"}
                "URL" {Write-Host "The field type is URL"}
                "User" {Write-Host "The field type is User"}
                default {Write-Host "The field type could not be detemined"}
            }
           
        }
    } while ($spQuery.ListItemCollectionPosition -ne $null)

    $SPWeb.AllowUnsafeUpdates = $false

    $SPWeb.Dispose()

}