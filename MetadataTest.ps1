<# 
    .Synopsis
     Applies a metadata value to a field based on the list name
    .DESCRIPTION
     For a given list this script will apply a metadata value to every item in this list based on the list name. This can be used to apply metadata not brought over in the migration
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
      Set-HUSPDocumentMetadata -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee" -group "EDRMS Fileplan" -set "Committees" -field "University Committee Name"
      Does what the script does
    .LINK
      A link (usually a link to where I stoled the script from)
#>

function MetadataTest {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=1)]
        [string]$url="https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees",
        [Parameter(Mandatory=$false,Position=2)]
        [string]$list="University Health and Safety Committee",
        [Parameter(Mandatory=$false,Position=3)]
        [string]$group="EDRMS Fileplan",
        [Parameter(Mandatory=$false,Position=4)]
        [string]$set="Committees",
        [Parameter(Mandatory=$false,Position=5)]
        [string]$field="University Committee Name"
    )
    

    #Get destination site and list
    $web = Get-SPWeb $url
    $listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list))
    $docLib = $web.Lists[$list]
    
    $web.AllowUnsafeUpdates = $true
    
    # Get the Term ID for the University Committee
    $committeeName = $list
    $ts = Get-SPTaxonomySession -Site $web.Site 
    $tstore = $ts.TermStores[0] 
    $tgroup = $tstore.Groups[$Group] 
    $tset = $tgroup.TermSets[$Set] 
    $term = $tset.GetTerms($committeeName, $true) 
    $termValueGuid = $term.Id
    
    # Create valid metadata object to apply to document
    $committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$docLib.Fields[$field]
    [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
    $taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + "|" + $termValueGuid) 

    # iterate through documents
    $items = $listname.items
    
    foreach ($item in $items) {
        $spItem = [Microsoft.SharePoint.SPListItem]$item;
        $CurrentRecord = $spItem["_dlc_DocId"].ToString()
        # Get taxonomy field
        $taxField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$spItem.Fields[$field]
        Write-Verbose -message "Checking $CurrentRecord"
        if($spItem[$field] -ne $null) {
            write-verbose -message "    $CurrentRecord **NOT** null in $field"
            $ModifyMetadata = {
                $CurrentTime = Get-Date -format yyyy-MM-dd_hh:mm
                $term = $taxonomyFieldValue.ValidatedString
                $myCheckString = $CurrentTime + " ; " + $term
                $taxField.SetFieldValue($term)
                $spItem["Document Description"] = $myCheckString
                $spItem.SystemUpdate($false)
            }
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($spItem, $ModifyMetadata)
        }
        else {
            Write-Verbose -message "    $CurrentRecord is null in $field"
            #Create New Site Object under Token of System Account for the Site Collection
            $ModifyMetadata = {
                $CurrentTime = Get-Date -format yyyy-MM-dd_hh:mm
                $term = $taxonomyFieldValue.ValidatedString
                $myCheckString = $CurrentTime + " ; " + $term
                $taxField.SetFieldValue($term)
                $spItem["Document Description"] = $myCheckString
                $spItem.SystemUpdate($false)
            }
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($spItem, $ModifyMetadata)
        }
    }  
    $web.AllowUnsafeUpdates = $false

    $web.Dispose()
}