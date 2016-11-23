<#
    .SYNOPSIS
    Creates a new managed metadata term set 
    .DESCRIPTION
    This script creates a new managed metadata term set. It also allows the creation of a synonym for that term which is not supported by the CSV import function.
    .PARAMETER url
    a valid SharePoint url
    .EXAMPLE
    New-HUSPMetadataTermSet -url https://devunifunctions.hud.ac.uk/COM will add a new term set
    .NOTES
    Some notes about the script
    .LINK
    stolen from; http://get-spscripts.com/2010/06/create-new-term-with-synonym-in.html
#>

function New-HUSPMetadataTermSet {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$group,
        [Parameter(Mandatory=$true,Position=3)]
        [string]$ts
    )
    
    #Connect to Central Admin 
    $TaxonomySite = Get-SPSite $url
    
    #Connect to Term Store in the Managed Metadata Service Application 
    $TaxonomySession = Get-SPTaxonomySession -site $TaxonomySite 
    
    <#
    We can specify the term store by name, but as there is just usually one, and this
    is certainly the case in our environment I am just going to use the first one
    $TermStore = $TaxonomySession.TermStores["Managed Metadata Service Application Proxy"]
    #> 
    
    $TermStore = $TaxonomySession.TermStores[0] 

    Write-Verbose "Connection made with term store - $TermStore.Name"
    
    #Connect to the Group and Term Set 
    $TermStoreGroup = $TermStore.Groups[$group] 
    $TermSet = $TermStoreGroup.TermSets[$ts] 
    
    #Create term, term description, and a synonym 
    $Term = $TermSet.CreateTerm("Test Term", 1033) 
    $Term.SetDescription("This is a test", 1033) 
    $Term.CreateLabel("This is a test synonym", 1033, $false) 
    
    #Update the Term Store 
    $TermStore.CommitAll() 
    
    #Dispose of taxonomy site object
    $TaxonomySite.Dispose()
}