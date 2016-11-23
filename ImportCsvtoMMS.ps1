# Outputs CSV of the specified termset from the specificed termstore/group
# Example call:
# .\ImportCsvtpMMS.ps1 "https://contoso.com:12345" "Managed Metadata Service"
param ([string]$centralAdminUrl = "https://contoso.com:12345",
[string] $termStoreName = "Managed Metadata Service",
[string]$configpath = "G:\Deployment\Artifacts\CommonScripts\contosocom12345_28042015_070531.csv"
)
Add-PSSnapin microsoft.sharepoint.powershell

$maxLevels = 5

$actions = @("add","update","delete")
$csvDictionary = New-Object 'system.collections.generic.dictionary[int,object]'

$caSite = get-spsite -Identity $centralAdminUrl
$taxSession = Get-SPTaxonomySession -Site $caSite
$termStore = $taxSession.TermStores[0]
$termGroups= $null;

if ($termStore -eq $null)
{
	$termStore = $taxSession.DefaultSiteCollectionTermStore
    $termGroups = $termStore.Groups
}

function ImportCsv()
{
    $id = 0;
    Import-Csv -Delimiter "," -Path $configpath | % {
        $obj = @{};
        $obj.Id = ++$id;
        $obj.TermGroup = $_.TermGroup
        $obj.TermSet = $_.TermSet
        $obj.Term = $_.Term
        $obj.Level2 = $_.Level2
        $obj.Level3 = $_.Level3
        $obj.Level4 = $_.Level4
        $obj.Level5 = $_.Level5
        $obj.UpdatedTitle = $_.UpdatedTitle
        $obj.Url = $_.Url
        $obj.FriendlyUrl = $_.FriendlyUrl
        $obj.CatalogTargetUrl = $_.CatalogTargetUrl
        $obj.CatalogChildTargetUrl = $_.CatalogChildTargetUrl
        $obj.TargetUrl = $_.TargetUrl
        $obj.ChildTargetUrl = $_.ChildTargetUrl
        $obj.LastModified = $_.LastModified
        $obj.Status = ""
        $obj.Action = $null;

        if ($_.Action -ne $null)
        {
            $obj.Action = $_.Action.tostring().tolower()
        }

        $object = new-object -TypeName PSObject -Property $obj
        $csvDictionary.Add($id, $object);
    }
}

function ProcessCsv()
{
    $csvDictionaryFiltered = $csvDictionary.Values | Where-Object {$_.Action -ne ""}
    
    foreach($obj in $csvDictionaryFiltered)
    {
        if (([string]::IsNullOrEmpty($obj.Action) -eq $false -and $actions.Contains($obj.Action)))
        {
            $action = $obj.Action.ToString().ToLower()

            switch($action)
            {
                "add"
                {               
                    addNewTerm -termobj $obj
                    break;
                }
                "update"
                {
                    updateExisitngTerm -obj $obj
                    break;
                }
                "delete"
                {
                    $_.Action
                    break;
                }
            }
        }
     }
}

function addNewTerm($termobj) 
{        
       [String]$group = $obj.TermGroup 
       [String]$set = $obj.TermSet
       [String]$Level1 = $obj.Term
       [String]$Level2 = $obj.Level2
       [String]$Level3 = $obj.Level3
       [String]$Level4 = $obj.Level4
       [String]$Level5 = $obj.Level5
          
                         
        $termgroup = $termstore.Groups | where { $_.Name -eq $group }
        if ($termgroup -eq $null) 
        {
            $termgroup = $termstore.CreateGroup($group)
        }
    
        $termset = $termgroup.TermSets | where { $_.Name -eq $set }
        if ($termset -eq $null) 
        {
            $termset = $termgroup.CreateTermSet($set)
        }

        if($Level1)
        {
           $level1term = createTerm -currentlevelTerm $termset  -levelName $Level1

            if($Level2)
            {
                $level2term = createTerm -currentlevelTerm $level1term  -levelName $Level2

                if($Level3)
                {
                    $level3term = createTerm -currentlevelTerm $level2term  -levelName $Level3

                    if($Level4)
                    {
                        $level4term = createTerm -currentlevelTerm $level3term  -levelName $Level4

                        if($Level5)
                        {
                          $level5term = createTerm -currentlevelTerm $level4term  -levelName $Level5
                        }
                    }
                }
            }
        }
    
}


function createTerm($currentlevelTerm,$levelName)
{
    $nextLevelTerm = $currentlevelTerm.Terms | Where { $_.Name -eq $levelName }
    if($nextLevelTerm -eq $null)
                            {
                                if($currentlevelTerm.IsPinned -eq $false)
                                {
                                    Write-Host "Createing Term-"$levelName
                                    $nextLevelTerm = $currentlevelTerm.CreateTerm($levelName, 1033)
                                    $termStore.CommitAll();
                                    $termStore.UpdateCache();
                                    $termStore.FlushCache();
                                }
                            } 

    
                                
    return $nextLevelTerm
}

function updateExisitngTerm($obj)
{
    
    [String]$group = $obj.TermGroup 
       [String]$set = $obj.TermSet
       [String]$Level1 = $obj.Term
       [String]$Level2 = $obj.Level2
       [String]$Level3 = $obj.Level3
       [String]$Level4 = $obj.Level4
       [String]$Level5 = $obj.Level5
       [String]$UpdatedTitle = $obj.UpdatedTitle

       $termgroup = $termstore.Groups | where { $_.Name -eq $group }
        if ($termgroup -eq $null) 
        {
            $termgroup = $termstore.CreateGroup($group)
        }
    
        $termset = $termgroup.TermSets | where { $_.Name -eq $set }
        if ($termset -eq $null) 
        {
            $termset = $termgroup.CreateTermSet($set)
        }

        if($Level1)
        {
           $level1term = createTerm -currentlevelTerm $termset  -levelName $Level1

            if($Level2)
            {
                $level2term = createTerm -currentlevelTerm $level1term  -levelName $Level2

                if($Level3)
                {
                    $level3term = createTerm -currentlevelTerm $level2term  -levelName $Level3

                    if($Level4)
                    {
                        $level4term = createTerm -currentlevelTerm $level3term  -levelName $Level4

                        if($Level5)
                        {
                          $level5term = createTerm -currentlevelTerm $level4term  -levelName $Level5
                        }
                    }
                }
            }
        }

        Write-Host "Updating Term-"$UpdatedTitle
        if($Level5)
        {            
           updateTermProperties -term $level5term -obj $obj;           
            
        }elseif($Level4)
        {
            updateTermProperties -term $level4term -obj $obj;           
        }
        elseif($Level3)
        {
             updateTermProperties -term $level3term -obj $obj;           
        }
        elseif($Level2)
        {
            updateTermProperties -term $level2term -obj $obj;           
        }
        elseif($Level1)
        {
             updateTermProperties -term $level1term -obj $obj;           
        }
}

function updateTermProperties($term,$obj)
{       
        if($term.IsPinned -eq $false)       
        {
            $term.Name = $obj.UpdatedTitle
        }
        $term.SetLocalCustomProperty("_Sys_Nav_SimpleLinkUrl",$obj.Url)
        $term.SetLocalCustomProperty("_Sys_Nav_FriendlyUrlSegment",$obj.FriendlyUrl)
        $term.SetLocalCustomProperty("_Sys_Nav_CatalogTargetUrl",$obj.CatalogTargetUrl)
        $term.SetLocalCustomProperty("_Sys_Nav_CatalogTargetUrlForChildTerms",$obj.CatalogChildTargetUrl)
        $term.SetLocalCustomProperty("_Sys_Nav_TargetUrl",$obj.TargetUrl)
        $term.SetLocalCustomProperty("_Sys_Nav_TargetUrlForChildTerms",$obj.ChildTargetUrl)

        try
        {
            $termStore.CommitAll();
            $termStore.UpdateCache();
            $termStore.FlushCache();
        }catch [Microsoft.SharePoint.Taxonomy.TermStoreOperationException]
        {
            Write-Host "Term already present - "$term.Name
        }
}

function deleteExisitngTerm()
{
}
 
function Main
{
    ImportCsv
    ProcessCsv    
}

Main