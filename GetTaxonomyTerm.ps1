Function GetTaxonomyTerm {

	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$spsite,
	[Parameter(Mandatory=$True,Position=2)]
	[string]$field,
	[Parameter(Mandatory=$True,Position=2)]
	[string]$label
	)
		
  Write-Host "Getting term for $($label)..."
	$taxonomySession = Get-SPTaxonomySession -Site $spsite
	$taxonomyField = $spsite.RootWeb.Fields.GetField($field)
	
	$termStoreID = $taxonomyField.SspId	
	$termStore = $taxonomySession.TermStores[$termStoreID]	
	
	$termsetID = $taxonomyField.TermSetId	
	$termset = $termStore.GetTermSet($termsetID)
	
	$term = $termset.GetTerms( $label, $true)
	
	return [string] $term[0].Name +"|"+$term[0].Id	
}
