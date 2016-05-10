<#
    .SYNOPSIS
    Sets Content Organizer Rules from a CSV file
    .DESCRIPTION
    This script will create a number of content organizer rules from a valid CSV file. See RuleTest001.csv for an example.
    .PARAMETER csv
    a valid CSV file with the rules
    .PARAMETER col
    a valid SharePoint Site Collection Url where you want the rules to be created
    .EXAMPLE
    Set-ContentOrganizerRules.ps1 -csv .\RuleTest001.csv -col https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees 
    .NOTES
    ! ! WARNING ! ! Use this script with caution, there is no error checking. Do not run unless you are exactly sure you know what to expect
#>

function New-HUSPContentOrganizerRules {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$col,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$csv
    )
    
    # Set the path of the CSV to use
    $contentRulesFile = Import-Csv -Path "$csv"
    $contentRulesList = $contentRulesFile
    
    [Microsoft.SharePoint.SPSite]$site = Get-SPSite $col
    
    foreach ($contentRule in $contentRulesList) {
    
        write-host Building $contentRule.Value content rule...
        $urlPath = $col + $contentRule.Web
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
}