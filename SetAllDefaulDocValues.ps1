<# 
Sets the University Committee Name to the correct metadata value based on the document library name
#>
Param(
    [string]$url,
    [string]$list
    )

Add-PSSnapin Microsoft.SharePoint.Powershell -ea SilentlyContinue

#Get destination site and list
$web = Get-SPWeb $url
$listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list))
$docLib = $web.Lists[$list]

# Get the Term ID for the University Committee
$committeeName = $list
$ts = Get-SPTaxonomySession -Site $web.Site 
$tstore = $ts.TermStores[0] 
$tgroup = $tstore.Groups["EDRMS Fileplan"] 
$tset = $tgroup.TermSets["Committees"] 
$term = $tset.GetTerms($committeeName, $true) 
$termValueGuid = $term.Id

$committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$docLib.Fields["University Committee Name"]
[Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
$taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + "|" + $termValueGuid) 

$items = $listname.items

foreach ($item in $items)
{
	if($item["University Committee Name"] -eq $null)
    {
        write-host Setting $item["Document ID"] to $taxonomyFieldValue.ValidatedString
        $item["University Committee Name"] = $taxonomyFieldValue.ValidatedString
        $item.Update()
    }
    else
    {
        write-host Value set to $item["University Committee Name"] 
    }
}