<# 
Title: Create organizer rules from CSV list
Author: Luke Brunning
Category: SharePoint EDRMS Scripts
Description
This script takes a CSV file of organizer rules and makes them in a site
#>

Param(
    [string]$csv,
    [string]$siteUrl
    )

if(-not($csv)) { Throw "You must enter a value for -csv"}

if(-not($siteUrl)) { Throw "You must enter a value for -siteUrl"}

#Add the SharePoint snapin
Add-PSSnapin Microsoft.SharePoint.Powershell -ea SilentlyContinue

# Set the path of the CSV to use
$contentRulesFile = Import-Csv -Path "$csv"
$contentRulesList = $contentRulesFile

[Microsoft.SharePoint.SPSite]$site = Get-SPSite $siteUrl

foreach ($contentRule in $contentRulesList) {

    write-host Building $contentRule.Value content rule...
    $urlPath = $siteUrl + $contentRule.Web
    [Microsoft.SharePoint.SPWeb]$web = Get-SPWeb $urlPath
    [Microsoft.SharePoint.SPContentType]$ct = $site.RootWeb.ContentTypes[$contentRule.ContentType]

    $committeeName = $contentRule.Value
    $ts = Get-SPTaxonomySession -Site $web.Site 
    $tstore = $ts.TermStores[0] 
    $tgroup = $tstore.Groups[$contentRule.TermStoreGroup] 
    $tset = $tgroup.TermSets[$contentRule.TermSet] 
    $term = $tset.GetTerms($committeeName, $true) 
    $termValueGuid = $term.Id

    $docLib = $web.Lists[$contentRule.DocLib] 
    $committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$docLib.Fields[$contentRule.TargetField]
    [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
    $taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + "|" + $termValueGuid) 

    [Microsoft.Office.RecordsManagement.RecordsRepository.EcmDocumentRouterRule]$rule = New-Object Microsoft.Office.RecordsManagement.RecordsRepository.EcmDocumentRouterRule($web)
    $rule.ConditionsString = "<Conditions><Condition Column='" + $committeeField.Id + $contentRule.TermPath + "' Operator='IsEqual' Value='" + $taxonomyFieldValue.ValidatedString + "'></Condition></Conditions>"
    $rule.CustomRouter = ""
    $rule.Name = "File " + $committeeName + " Documents"
    $rule.Description = "Routes " + $committeeName + " documents to their own library"
    $rule.ContentTypeString = $ct.Name
    $rule.RouteToExternalLocation = $false
    $rule.Priority = "5"
    $rule.TargetPath = $web.Lists[$committeeName].RootFolder.ServerRelativeUrl
    $rule.Enabled = $true
    $rule.Update()
    $web.Dispose()
    $site.Dispose()
} 