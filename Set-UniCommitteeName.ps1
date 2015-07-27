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

if ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) { Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$web = Get-SPWeb $url
$listName = $web.GetList(($web.ServerRelativeURL.TrimEnd('/') + '/' + $list))
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
$taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + '|' + $termValueGuid) 

$items = $listname.items

foreach ($item in $items) {
    $currentItemName = $item['Name'].ToString();
    write-verbose -message "Checking $currentItemName University Committee Name"
    if($item["University Committee Name"] -eq $null) {
        write-debug -message "Set $currentItemName University Committee Name to $taxonomyFieldValue"
        # $item["University Committee Name"] = $taxonomyFieldValue.ValidatedString
        # $item.Update()
    } else { write-debug "University Committee Name is already set" }
    write-verbose -message "Checking $currentItemName Commmittee Document Type"
    if($item["Committee Document Type"] -eq $null) {
        if($item["Name"] -match "Agenda") {
            write-debug "Agenda"
            # $item["Committee Document Type"] = $listName.Fields["Committee Document Type"].GetFieldValue("Agenda")
            # $item.Update()
        } elseif($item["Name"] -match "Minutes") {
            write-debug "Minutes"
            # $item["Committee Document Type"] = $listName.Fields["Committee Document Type"].GetFieldValue("Minutes")
            # $item.Update()
        } else {
            write-debug "Paper"
            # $item["Committee Document Type"] = $listName.Fields["Committee Document Type"].GetFieldValue("Paper")
            # $item.Update()
        }
    } else { write-debug "Committee Document Type is already set" }
    # break
}

$web.Dispose()