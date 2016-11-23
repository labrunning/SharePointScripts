function Get-HUSPMetadataValue {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$group,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$set,
        [Parameter(Mandatory=$True,Position=4)]
        [string]$label,
        [Parameter(Mandatory=$True,Position=5)]
        [string]$field
    )
        
	$SPSite = Get-SPSite $url
    
    $TaxonomySession = Get-SPTaxonomySession -Site $SPSite.Url 
    $TaxonomyField = $SPSite.RootWeb.Fields.GetField($field)    
    
    $TermStoreID = $TaxonomyField.SspId  
    $TermStore = $TaxonomySession.TermStores[$TermStoreID]
    
    $TermSetID = $TaxonomyField.TermSetId    
    $TermSet = $TermStore.GetTermSet($TermSetID) 
    
    $Term =  $TermSet.GetTerms($label, $true)
    
    return [string] $Term[0].Name +"|"+$Term[0].Id   
    
    $SPSite.Dispose()

}