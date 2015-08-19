<# 
.SYNOPSIS
Sets the committee name in a document library according to that document library name
.DESCRIPTION
For every item in a document library, this script will look for empty University Committee Name fields and fill them with the Managed Metadata value which matches with the Document Library name.
.PARAMETER url
a valid SharePoint URL of a site
.PARAMETER list
a valid name of a document library
.EXAMPLE
SetCommitteeNames.ps1 -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -list "University Health and Safety Committee"
.NOTES
**WARNING** Use at your own risk, there are only rudimentary checks in this script
.LINK
a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>

Param(
    [string]$url,
    [string]$list
    )

write-verbose "Loading the SharePoint Powershell Snapin if not already loaded"

Add-PSSnapin Microsoft.SharePoint.Powershell -ea SilentlyContinue

write-verbose 'Setting the list variables'

$web = Get-SPWeb $url
$listName = $web.GetList(($web.ServerRelativeURL.TrimEnd('/') + '/' + $list))
$docLib = $web.Lists[$list]

write-verbose 'Getting the term ID value from Managed Metadata'

$committeeName = $list
$ts = Get-SPTaxonomySession -Site $web.Site 
$tstore = $ts.TermStores[0] 
$tgroup = $tstore.Groups["EDRMS Fileplan"] 
$tset = $tgroup.TermSets["Committees"] 
$term = $tset.GetTerms($committeeName, $true) 
$termValueGuid = $term.Id

$committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$docLib.Fields["University Committee Name"]
[Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
$taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + '|' + $termValueGuid) 

write-verbose 'Get all the items in the list'

$items = $listname.items

write-verbose 'Set values for each item'

foreach ($item in $items) {

    write-verbose 'Check University Committee Name'

    if($item["University Committee Name"] -eq $null) {

	    write-debug 'Setting $item["Name"] to $taxonomyFieldValue.ValidatedString'

        # $item["University Committee Name"] = $taxonomyFieldValue.ValidatedString
        # $item.Update()
    } else { write-debug 'University Committee Name is set to $item["University Committee Name"]' }

    write-verbose 'Check Commmittee Document Type'

    if($item["Committee Document Type"] -eq $null) {
        if($item["Name"] -contains "Agenda") {

            write-debug 'Setting $item["Name"] to Agenda'

            # $item["Committee Document Type"] = $listName.Fields["Committee Document Type"].GetFieldValue("Agenda")
            # $item.Update()
        } else {

            write-debug 'Setting $item["Name"] to Paper'

            # $item["Committee Document Type"] = $listName.Fields["Committee Document Type"].GetFieldValue("Paper")
            # $item.Update()
        }
    } else { write-debug 'Committee Document Type is set to $item["Committee Document Type"]' }
}