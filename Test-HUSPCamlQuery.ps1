function Test-HUSPCamlQuery {


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$xml
    )
    
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    
    $spQuery = New-Object Microsoft.SharePoint.SPQuery
    $spQuery.ViewAttributes = "Scope='Recursive'"
    $caml = Get-Content $xml -Raw
    $spQuery.Query = $caml 
    
    do {
        $SPListItems = $SPList.GetItems($spQuery)
        $spQuery.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        foreach($SPItem in $SPListItems) {
            $SPItem | Select Name,Id,Title
        }
    }
    while ($spQuery.ListItemCollectionPosition -ne $null)

    $SPQueryCount = $SPListItems.Count
    Write-Output "--------------------------------------------------------------------------------"
    Write-Output "Total number of items in $SPList is $SPQueryCount"
    Write-Output "--------------------------------------------------------------------------------"

    $SPWeb.Dispose()
}