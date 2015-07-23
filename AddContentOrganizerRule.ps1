#Add the SharePoint snapin
Add-PSSnapin Microsoft.SharePoint.Powershell -ea SilentlyContinue

# Set the sites and the Content Type
[Microsoft.SharePoint.SPSite]$site = Get-SPSite https://devunishare.hud.ac.uk
[Microsoft.SharePoint.SPWeb]$web = Get-SPWeb https://devunishare.hud.ac.uk/demo/COM/University-Committees/
[Microsoft.SharePoint.SPContentType]$ct = $site.RootWeb.ContentTypes["EDRMS University Committee"]

# Get the term ID
$committeeName = "Senate"
$ts = Get-SPTaxonomySession -Site $web.Site 
$tstore = $ts.TermStores[0] 
$tgroup = $tstore.Groups["EDRMS Fileplan"] 
$tset = $tgroup.TermSets["Committees"] 
$term = $tset.GetTerms($committeeName, $true) 
$termValueGuid = $term.Id


$docLib = $web.Lists["@Drop Off Library"] 
$committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$docLib.Fields["University Committee Name"]
[Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
$taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + "|" + $termValueGuid) 

[Microsoft.Office.RecordsManagement.RecordsRepository.EcmDocumentRouterRule]$rule = New-Object Microsoft.Office.RecordsManagement.RecordsRepository.EcmDocumentRouterRule($web)
# $rule.Aliases = $ct.Name
$rule.ConditionsString = "<Conditions><Condition Column='" + $committeeField.Id + "|Committees|University Committees' Operator='IsEqual' Value='" + $taxonomyFieldValue.ValidatedString + "'></Condition></Conditions>"
$rule.CustomRouter = ""
$rule.Name = "File " + $committeeName + " Documents"
$rule.Description = "Routes " + $committeeName + " documents to their own library"
$rule.ContentTypeString = $ct.Name
$rule.RouteToExternalLocation = $false
$rule.Priority = "5"
$rule.TargetPath = $web.Lists[$committeeName].RootFolder.ServerRelativeUrl
$rule.Enabled = $true
$rule.Update()

 