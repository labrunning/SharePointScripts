
function Get-ManagedMetadataFieldUses
{
	################################################################
	#.Synopsis
	# Gets a list of fields referencing a Taxonomy (Managed Metadata) TermSet. 
	#.DESCRIPTION
	# Use this function to get a list of fields that reference a Taxonomy (Managed Metadata) TermSet. This function returns a collection of objects containing the field name and id, the list the field is from, and the web the list is in.
	#.Parameter Web
	#  The SPWeb to search.
	#.Parameter TermSet
	#  Find fields using this TermSet object (Microsoft.SharePoint.Taxonomy.TermSet).
	#.Parameter Recurse
	#  Check the SPWeb's sub webs.
	#.Parameter WebLevelFieldsOnly
	#  Only check fields created at the web level.
	#.OUTPUTS
	#  A collection of objects containing the field name and id, the list the field is from, and the web the list is in.
	#.EXAMPLE 
	#  $matchingFields = Get-ManagedMetadataFieldUses -web (Get-SPWeb http://sharepointsite) -TermSet $termSet -Recurse
	#  Get a list of all the fields in the http://sharepointsite web that reference the TermSet in the $termSet variable. Check all lists and sub webs.	
	################################################################
	[CmdletBinding()]
		Param(	 
				[parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)][Microsoft.SharePoint.SPWeb]$Web,
				[parameter(Mandatory=$true, Position=2)][Microsoft.SharePoint.Taxonomy.TermSet]$TermSet,				
				[parameter(Mandatory=$false, Position=4)][switch]$Recurse,
				[parameter(Mandatory=$false, Position=5)][switch]$WebLevelFieldsOnly
			)	
	
	$matches = @();	
	$matches += Get-FieldsUsingTermSet $Web.Fields $TermSet;
	
	if($WebLevelFieldsOnly -eq $false)
	{
		foreach($list in $Web.Lists)
		{
			$matches += Get-FieldsUsingTermSet $list.Fields $TermSet
		}
	}
	
	if($Recurse)
	{
		foreach($subweb in $Web.Webs)
		{
			$matches += Get-ManagedMetadataFieldUses $subweb $TermSet $Recurse $WebLevelFieldsOnly;
		}
	}
	
	return $matches
}

function Get-FieldsUsingTermSet
{
	################################################################
	#.Synopsis
	# Gets a list of fields in an SPFieldCollection, referencing a Taxonomy (Managed Metadata) TermSet. 
	#.DESCRIPTION
	# Use this function to get a list of fields in an SPFieldCollection, that reference a Taxonomy (Managed Metadata) TermSet. This function returns a collection of objects containing the field name and id, the list the field is from, and the web the list is in.
	#.Parameter FieldCollection
	#  The SPFieldCollection to search.
	#.Parameter TermSet
	#  Find fields using this TermSet object (Microsoft.SharePoint.Taxonomy.TermSet).	
	#.OUTPUTS
	#  A collection of objects containing the field name and id, the list the field is from, and the web the list is in.
	#.EXAMPLE 
	#  $matchingFields = Get-FieldsUsingTermSet -FieldCollection (Get-SPWeb http://sharepointsite).Lists["Documents"].Fields -TermSet $termSet
	#  Get a list of all the fields in the Documents library, from the http://sharepointsite web, that reference the TermSet in the $termSet variable.
	################################################################
	[CmdletBinding()]
		Param(	 
				[parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)][Microsoft.SharePoint.SPFieldCollection]$FieldCollection,
				[parameter(Mandatory=$true, Position=2)][Microsoft.SharePoint.Taxonomy.TermSet]$TermSet
			)
	$MetadataField = New-Object psobject
	$MetadataField | Add-Member -MemberType NoteProperty -Name "ParentListUrl" -value ""
	$MetadataField | Add-Member -MemberType NoteProperty -Name "ParentListTitle" -value ""
	$MetadataField | Add-Member -MemberType NoteProperty -Name "FieldTitle" -value ""
	$MetadataField | Add-Member -MemberType NoteProperty -Name "FieldId" -value ""
	
	$matches = @();
	foreach($field in $FieldCollection)
	{
		if($field.GetType().Name -ne "TaxonomyField"){
			continue;
		}
		if($field.TermSetId.ToString() -ne $TermSet.Id.ToString()){continue;}
		$tf = $MetadataField | Select-Object *;
		$tf.ParentListUrl = $field.ParentList.ParentWeb.Url;
		$tf.ParentListTitle = $field.ParentList.Title;
		$tf.FieldTitle = $field.Title;
		$tf.FieldId = $field.ID;
		$matches += $tf;
	}
	return $matches;
}

function Get-TermSet{
	################################################################
	#.Synopsis
	# Gets a list of fields in an SPFieldCollection, referencing a Taxonomy (Managed Metadata) TermSet. 
	#.DESCRIPTION
	# Use this function to get a list of fields in an SPFieldCollection, that reference a Taxonomy (Managed Metadata) TermSet. This function returns a collection of objects containing the field name and id, the list the field is from, and the web the list is in.
	#.Parameter FieldCollection
	#  The SPFieldCollection to search.
	#.Parameter TermSet
	#  Find fields using this TermSet object (Microsoft.SharePoint.Taxonomy.TermSet).	
	#.OUTPUTS
	#  A collection of objects containing the field name and id, the list the field is from, and the web the list is in.
	#.EXAMPLE 
	#  $matchingFields = Get-FieldsUsingTermSet -FieldCollection (Get-SPWeb http://sharepointsite).Lists["Documents"].Fields -TermSet $termSet
	#  Get a list of all the fields in the Documents library, from the http://sharepointsite web, that reference the TermSet in the $termSet variable.
	################################################################
	[CmdletBinding()]
		Param(	 
				[parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)][Microsoft.SharePoint.SPWeb]$web,				
				[parameter(Mandatory=$false, Position=2)][switch]$UseDefaultTermStore,
				[parameter(Mandatory=$false, Position=3)][object]$TermStoreId,
				[parameter(Mandatory=$true, Position=4)][object]$TermSetId
			)
	if($UseDefaultTermStore -eq $false -and $TermStoreId -eq $null)
	{
		throw "You must provide a value for the term store, or use the UseDefaultTermStore switch";
	}
	
	$tsession = Get-SPTaxonomySession -Site $web.Site;
	$tstore =  $null;
	if($UseDefaultTermStore -eq $true)
	{
		$tstore =  $tsession.TermStores[($tsession.TermStores[0]).ID];
	}
	else
	{
		if($TermStoreId.GetType().Name -eq "Guid")
		{
			$tstore =  $tsession.TermStores[$TermStoreId];
		}
		else{
			$tstore =  $tsession.TermStores[[Guid]$TermStoreId];
		}		
	}
	$tSet = $null;
	if($TermSetId.GetType().Name -eq "Guid")
	{
		$tSet = $tstore.GetTermSet($TermSetId);
	}
	else{
		$tSet = $tstore.GetTermSet([Guid]$TermSetId);
	}	
	return $tSet;
}

function List-TermStores{
	[CmdletBinding()]
		Param(	 
				[parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$web
			)
	$tsession = Get-SPTaxonomySession -Site $web.Site;	
	$tsession.TermStores | FT Name,ID;
}

function List-AllTermSets{
	[CmdletBinding()]
		Param(	 
				[parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$web
			)
	$termSetInfo = New-Object psobject
	$termSetInfo | Add-Member -MemberType NoteProperty -Name "Store" -value ""
	$termSetInfo | Add-Member -MemberType NoteProperty -Name "StoreId" -value ""
	$termSetInfo | Add-Member -MemberType NoteProperty -Name "Group" -value ""
	$termSetInfo | Add-Member -MemberType NoteProperty -Name "GroupId" -value ""
	$termSetInfo | Add-Member -MemberType NoteProperty -Name "TermSet" -value ""
	$termSetInfo | Add-Member -MemberType NoteProperty -Name "TermSetId" -value ""
	
	$tsession = Get-SPTaxonomySession -Site $web.Site;
	$tstores =  $tsession.TermStores;	
	$list = @();
	foreach($tstore in $tstores)
	{
		$tgroups = $tstore.Groups;
		foreach($tgroup in $tgroups)
		{
			$tsets = $tgroup.TermSets;
			foreach($tset in $tsets)
			{
				$tinfo = $null;
				$tinfo = $termSetInfo | Select-Object *;
				$tinfo.Store = $tstore.Name;
				$tinfo.StoreId = $tstore.ID;
				$tinfo.Group = $tgroup.Name;
				$tinfo.GroupId = $tgroup.ID;
				$tinfo.TermSet = $tSet.Name;
				$tinfo.TermSetId = $tSet.ID;
				$list += $tinfo;
			}
		}	
	}
	return $list;
}

