<#
    .SYNOPSIS
    Sets Content Organizer Rules for a document library
    .DESCRIPTION
    This script will create a content organizer rule for a document library.
    .PARAMETER url
    a valid SharePoint site URL
    .PARAMETER lib
    a valid SharePoint document library
    .PARAMETER tsg
    a valid SharePoint term store group
    .PARAMETER ts
    a valid SharePoint term set
    .EXAMPLE
    New-HUSPTestContentOrganizerRules -url https://testunifunctions.hud.ac.uk/COM/University-Committees -lib "Athena Swan" -tsg "UF Fileplan" -ts "Committees"  
    .NOTES
    ! ! WARNING ! ! Use this script with caution, there is no error checking. Do not run unless you are exactly sure you know what to expect
#>

function New-HUSPContentOrganizerRules {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$tsg,
        [Parameter(Mandatory=$True,Position=4)]
        [string]$ts
    )
    
    $SPWeb = Get-SPWeb $url

    # Get the site so we can get a taxonomy session and content types
    $SPSite = Get-SPSite $SPWeb.Site

    # Get the document library we are creating the rule for
    $SPList = $SPWeb.Lists[$list]
    
    # Set content type we are using
    $SPContentType = $SPList.ContentTypes | Where-Object { $_.Name -ne "Folder" }
    Write-Verbose $SPContentType

    # Establish taxonomy session 
    $taxonomySession = Get-SPTaxonomySession -Site $SPWeb.Site 
    $tstore = $taxonomySession.TermStores[0] 
    $tgroup = $tstore.Groups[$tsg] 
    $tset = $tgroup.TermSets[$ts]
    $term =  $tset.GetTerms($SPList.Title,$true) | Where { $_.Parent.Name -eq $SPContentType.Name }
    $termValueGuid = $term.Id
    # $termValueGuid        
    
    # Create valid term label
    $committeeName = $SPList.Title
    $committeeField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$SPList.Fields[$SPContentType.Name]
    [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$taxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($committeeField)    
    $taxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($committeeName) + "|" + $termValueGuid) 
    
    # Create the rule
    [Microsoft.Office.RecordsManagement.RecordsRepository.EcmDocumentRouterRule]$rule = New-Object Microsoft.Office.RecordsManagement.RecordsRepository.EcmDocumentRouterRule($SPWeb)
    $rule.ConditionsString = "<Conditions><Condition Column='" + $committeeField.Id + "|" + $committeeField.Name + "|" + $committeeField.DisplayName + "' Operator='IsEqual' Value='" + $taxonomyFieldValue.ValidatedString + "'></Condition></Conditions>"
    $rule.CustomRouter = ""
    $rule.Name = "File " + $committeeName + " Documents"
    $rule.Description = "Routes " + $committeeName + " documents to their own library"
    
    # Get the content type from the document library
    $rule.ContentTypeString = $SPContentType.Name
    
    $rule.RouteToExternalLocation = $false
    $rule.Priority = "5"
    $rule.TargetPath = $SPWeb.Lists[$committeeName].RootFolder.ServerRelativeUrl
    $rule.Enabled = $true
    Write-Verbose -message "Creating organise rule in $SPWeb for $committeeName with $taxonomyFieldValue "
    $rule.Update()
    # Let go!
    $SPWeb.Dispose()
    $SPSite.Dispose()

}