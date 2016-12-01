function Clear-MetadataField{
	[CmdletBinding()]
	Param(				
			[parameter(Mandatory=$true)][Microsoft.SharePoint.SPListItemCollection]$items, 
			[parameter(Mandatory=$true)][string]$MetadataFieldInternalName, 
			[parameter(Mandatory=$false)][string]$ItemId, 		   
			[parameter(Mandatory=$false)][switch]$ClearAllItems
		)
	$web = $items.List.ParentWeb;	
	try
	{
		$baselist = $items.List;		
		$t = $baselist.GetType();		
		$list = $null
		if($t.Name -eq "SPDocumentLibrary")
		{
			$list = $items.List -as [Microsoft.SharePoint.SPDocumentLibrary];
			if($ClearAllItems)
			{				
				foreach($item in $items)
				{
					$url = [String]::Format("{0}{1}",$web.Url, $item.File.Url);
					$file = $web.GetFile($url);
					if($file.CheckOutStatus -eq "None")
					{
						$file.CheckOut();
						ClearTaxonomyFieldValue -item $file.Item -taxonomyField ($file.Item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField])
						$file.CheckIn("Updated Taxonomy Field Value");
						$msg = [String]::Format("Item, {0}, updated.",$file.Name);
						Write-Output $msg -ForegroundColor Green;
					}
					else
					{
						$msg = [String]::Format("This file, {0}, is checked out and cannot be edited at the moment",$file.Name);
						Write-Output $msg -ForegroundColor DarkYellow;
					}					
				}
			}
			if($ItemId -ne $null -and $ClearAllItems -eq $false)
			{
				$item = $list.GetItemById($ItemId);
				$url = [String]::Format("{0}{1}",$web.Url, $item.File.Url);
				$file = $web.GetFile($url);
				if($file.CheckOutStatus -eq "None")
				{
					$file.CheckOut();
					ClearTaxonomyFieldValue -item $file.Item -taxonomyField ($file.Item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField])
					$file.CheckIn("Updated Taxonomy Field Value");
					$msg = [String]::Format("Item, {0}, updated.",$file.Name);
					Write-Output $msg -ForegroundColor Green;
				}
				else
				{
					$msg = [String]::Format("This file, {0}, is checked out and cannot be edited at the moment",$file.Name);
					Write-Output $msg -ForegroundColor DarkYellow;
				}
			}
		}
		else
		{
			$list = $items.List;			
			if($ClearAllItems)
			{
				$items = $list.Items;
				foreach($item in $items)
				{
					ClearTaxonomyFieldValue -item $item -taxonomyField ($item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField])
					$msg = [String]::Format("Item, {0}, updated.",$item.Title);
					Write-Output $msg -ForegroundColor Green;
				}
			}
			if($ItemId -ne $null -and $ClearAllItems -eq $false)
			{
				$item = $list.GetItemById($ItemId);			
				ClearTaxonomyFieldValue -item $item -taxonomyField ($item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField])
				$msg = [String]::Format("Item, {0}, updated.",$item.Title);
				Write-Output $msg -ForegroundColor Green;
			}
		}
	}
	catch [System.SystemException]
    { 
        Write-Output "The script has stopped because there has been an error.  "$_  -foregroundcolor Red
    }
    finally
    {
        $web.Dispose()
    }	
}

function Update-MetadataField{
	[CmdletBinding()]
	Param(				
			[parameter(Mandatory=$true)][Microsoft.SharePoint.SPListItemCollection]$items, 
			[parameter(Mandatory=$true)][string]$MetadataFieldInternalName,
			[parameter(Mandatory=$true)][string]$taxonomyFieldValueId,			
			[parameter(Mandatory=$false)][string]$ItemId, 		   
			[parameter(Mandatory=$false)][switch]$UpdateAllItems
		)
	$web = $items.List.ParentWeb;	
	try
	{
		$baselist = $items.List;		
		$t = $baselist.GetType();		
		$list = $null
		if($t.Name -eq "SPDocumentLibrary")
		{
			$list = $items.List -as [Microsoft.SharePoint.SPDocumentLibrary];
			if($UpdateAllItems)
			{				
				foreach($item in $items)
				{
					$url = [String]::Format("{0}{1}",$web.Url, $item.File.Url);
					$file = $web.GetFile($url);
					if($file.CheckOutStatus -eq "None")
					{
						$file.CheckOut();
						UpdateTaxonomyFieldValue -item $file.Item -taxonomyField ($file.Item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField]) -taxonomyFieldValueId $taxonomyFieldValueId;
						$file.CheckIn("Updated Taxonomy Field Value");
						$msg = [String]::Format("Item, {0}, updated.",$file.Name);
						Write-Output $msg -ForegroundColor Green;
					}
					else
					{
						$msg = [String]::Format("This file, {0}, is checked out and cannot be edited at the moment",$file.Name);
						Write-Output $msg -ForegroundColor DarkYellow;
					}					
				}
			}
			if($ItemId -ne $null -and $UpdateAllItems -eq $false)
			{
				$item = $list.GetItemById($ItemId);
				$url = [String]::Format("{0}{1}",$web.Url, $item.File.Url);
				$file = $web.GetFile($url);
				if($file.CheckOutStatus -eq "None")
				{
					$file.CheckOut();
					UpdateTaxonomyFieldValue -item $file.Item -taxonomyField ($file.Item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField]) -taxonomyFieldValueId $taxonomyFieldValueId;
					$file.CheckIn("Updated Taxonomy Field Value");
					$msg = [String]::Format("Item, {0}, updated.",$file.Name);
					Write-Output $msg -ForegroundColor Green;
				}
				else
				{
					$msg = [String]::Format("This file, {0}, is checked out and cannot be edited at the moment",$file.Name);
					Write-Output $msg -ForegroundColor DarkYellow;
				}
			}
		}
		else
		{
			$list = $items.List;			
			if($UpdateAllItems)
			{
				$items = $list.Items;
				foreach($item in $items)
				{
					UpdateTaxonomyFieldValue -item $item -taxonomyField ($item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField]) -taxonomyFieldValueId $taxonomyFieldValueId;
					$msg = [String]::Format("Item, {0}, updated.",$item.Title);
					Write-Output $msg -ForegroundColor Green;
				}
			}
			if($ItemId -ne $null -and $UpdateAllItems -eq $false)
			{
				$item = $list.GetItemById($ItemId);			
				UpdateTaxonomyFieldValue -item $item -taxonomyField ($item.Fields[$MetadataFieldInternalName] -as [Microsoft.SharePoint.Taxonomy.TaxonomyField]) -taxonomyFieldValueId $taxonomyFieldValueId;
				$msg = [String]::Format("Item, {0}, updated.",$item.Title);
				Write-Output $msg -ForegroundColor Green;
			}
		}
	}
	catch [System.SystemException]
    { 
        Write-Output "The script has stopped because there has been an error.  "$_  -foregroundcolor Red
    }
    finally
    {
        $web.Dispose()
    }	
}
	
function ClearTaxonomyFieldValue{
	[CmdletBinding()]
	Param 	(
			[parameter(Mandatory=$true)][Microsoft.SharePoint.SPListItem]$item,	
			[parameter(Mandatory=$true)][Microsoft.SharePoint.Taxonomy.TaxonomyField]$taxonomyField			
			)			
	$taxFieldValue = $taxonomyField.GetFieldValue("");
	$taxonomyField.SetFieldValue($item,$taxFieldValue);
	$item.Update();
}		

function UpdateTaxonomyFieldValue{
	[CmdletBinding()]
	Param 	(
			[parameter(Mandatory=$true)][Microsoft.SharePoint.SPListItem]$item,	
			[parameter(Mandatory=$true)][Microsoft.SharePoint.Taxonomy.TaxonomyField]$taxonomyField,
			[parameter(Mandatory=$true)][string]$taxonomyFieldValueId
		)
	$ts = Get-SPTaxonomySession -Site $taxonomyField.ParentList.ParentWeb.Site;
	$term = $ts.GetTerm($taxonomyFieldValueId);
	$taxonomyField.SetFieldValue($item,$term);	
	$item.Update();
}	
	
function Get-TaxonomyTerms{
	[CmdletBinding()]
	Param 	(
			[parameter(Mandatory=$true)][string]$webUrl,	
			[parameter(Mandatory=$true)][string]$termStoreName,
			[parameter(Mandatory=$true)][string]$termGroup,
			[parameter(Mandatory=$true)][string]$termSet,
			[parameter(Mandatory=$false)][string]$termName
			)	
	$ts = Get-SPTaxonomySession -Site $webUrl;
	$tstore = $ts.TermStores[$termStoreName];
	$tgroup = $tstore.Groups[$termGroup];
	$tset = $tgroup.TermSets[$termSet];
	if($termName -eq "")
	{
		$tset.Terms | FT Name,Parent,ID;
	}
	else
	{
		foreach($t in $tset.Terms)
		{
			if($t.Name -eq $termName)
			{
				$t | FT Name,Parent,ID;				
			}
		}
	}
}	

function Get-TaxonomyTermStores{
	[CmdletBinding()]
	Param 	(
			[parameter(Mandatory=$true)][string]$webUrl
			)	
	$ts = Get-SPTaxonomySession -Site $webUrl;
	$ts.TermStores | FT ID,Name,Groups -AutoSize
}	

function Get-TaxonomyTermSets{
	[CmdletBinding()]
	Param 	(
			[parameter(Mandatory=$true)][string]$webUrl,
			[parameter(Mandatory=$true)][string]$termStoreName,
			[parameter(Mandatory=$true)][string]$termGroup
			)	
	$ts = Get-SPTaxonomySession -Site $webUrl;
	$tstore = $ts.TermStores[$termStoreName];
	$tgroup = $tstore.Groups[$termGroup];	
	$tgroup.TermSets.GetEnumerator() | FT ID,Name -AutoSize	
}
