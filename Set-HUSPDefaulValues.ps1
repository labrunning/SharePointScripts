<#
    .SYNOPSIS
    Sets default values for all documents in a library
    .DESCRIPTION
    Currently this only works for the University Health and Safety Committee and just adds the managed metadata University Committee Name according to the document library name
    .PARAMETER url
    a valid SharePoint site url
    .PARAMETER list
    a valid SharePoint document library list
    .EXAMPLE
        Set-HUSPDefaulValues https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees 'University Health and Safety Committee'
    .NOTES
    TODO: some checking to see if this is the right document library (could use Content Type?)
#>

function Set-HUSPDefaulValues {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$list
    )

    $web = Get-SPWeb $url
    $listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list))
    $docLib = $web.Lists[$list]
    
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
}