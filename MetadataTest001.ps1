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

function MetadataTest001 {

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
    
    # Get destination site and list
    $web = Get-SPWeb $url
    $listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list)) -as [Microsoft.SharePoint.SPDocumentLibrary]
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

    # $term
    
    # Create valid metadata object to apply to document
    $committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$docLib.Fields[$field]
    [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
    $taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + "|" + $termValueGuid) 

    # Get empty University Committee Name items
    $query = New-Object Microsoft.SharePoint.SPQuery
    $query.ViewAttributes = "Scope='Recursive'"
    $query.RowLimit = 2000
    $query.ViewFields = '<FieldRef Name="University_x0020_Committee_x0020_Name" /><FieldRef Name="_dlc_DocId" /><FieldRef Name="Document Description" />'
    $caml = '<Where><IsNull><FieldRef Name="University_x0020_Committee_x0020_Name" /></IsNull></Where>'
    # $caml = '<OrderBy><FieldRef Name="_dlc_DocId" /></OrderBy>'
    # $caml = '<Where><BeginsWith><FieldRef Name="ID" /><Value Type="Integer">1</Value></BeginsWith></Where>'
    $query.Query = $caml 

    do 
    {
        $listItems = $docLib.GetItems($query)
        $query.ListItemCollectionPosition = $listItems.ListItemCollectionPosition
        
        foreach($item in $listItems)
        {
            $SPItem = [Microsoft.SharePoint.SPListItem]$item
            $CurrentRecord = $SPItem['_dlc_DocId'].ToString()
            Write-Verbose -message "Checking $CurrentRecord"
            $ModifyMetadata = {
                $CurrentTime = Get-Date -format yyyy-MM-dd_hh:mm
                $myCheckString = "Edited " + $CurrentRecord + " at " + $CurrentTime
                # $SPItem['Document Description'] = $myCheckString
                $SPItem[$field] = $taxonomyFieldValue.ValidatedString
                $SPItem.SystemUpdate($false)
            }
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($SPItem, $ModifyMetadata)
        }
    }
    while ($query.ListItemCollectionPosition -ne $null)
    
    $web.AllowUnsafeUpdates = $false
    $web.Dispose()
}