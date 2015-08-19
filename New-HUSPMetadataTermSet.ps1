<#
    .SYNOPSIS
    Creates a new managed metadata term set 
    .DESCRIPTION
    This script creates a new managed metadata term set. It also allows the creation of a synonym for that term which is not supported by the CSV import function.
    .PARAMETER param
    a description of a parameter
    .EXAMPLE
    An example of how the script can be used
    .NOTES
    Some notes about the script
    .LINK
    stolen from; http://get-spscripts.com/2010/06/create-new-term-with-synonym-in.html
#>

function New-HUSPMetadataTermSet {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list
    )
    
    #Connect to Central Admin 
    $TaxonomySite = Get-SPSite $url
    
    #Connect to Term Store in the Managed Metadata Service Application 
    $TaxonomySession = Get-SPTaxonomySession -site $TaxonomySite 
    $TermStore = $TaxonomySession.TermStores["Managed Metadata Service"] 
    Write-Verbose "Connection made with term store - $TermStore.Name"
    
    #Connect to the Group and Term Set 
    $TermStoreGroup = $TermStore.Groups["Group Name"] 
    $TermSet = $TermStoreGroup.TermSets["Term Set Name"] 
    
    #Create term, term description, and a synonym 
    $Term = $TermSet.CreateTerm("Test Term", 1033) 
    $Term.SetDescription("This is a test", 1033) 
    $Term.CreateLabel("This is a test synonym", 1033, $false) 
    
    #Update the Term Store 
    $TermStore.CommitAll() 
    
    #Dispose of taxonomy site object
    $TaxonomySite.Dispose()
}