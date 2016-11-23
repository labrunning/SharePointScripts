<#
    ################################################################
    .Synopsis
     Runs through a list using a CAML query to get the relevant items to try and save memory or target certain items
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter url
     A description of the url parameter
    .Parameter list
     A description of the url parameter
    .OUTPUTS
     A description of what the script outputs
    .EXAMPLE
     An example of the command in use
    ################################################################
#>

function Test-HUSPLargeList {    

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$xml
    )

    #Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    
    $spQuery = New-Object Microsoft.SharePoint.SPQuery
    $caml = Get-Content $xml -Raw
    $spQuery.Query = $caml 

    do {
        $SPListItems = $SPList.GetItems($spQuery)
        $spQuery.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        foreach($SPItem in $SPListItems) {
            # Get current record information
            $SPItem | Select Name,Id
        }
    } while ($spQuery.ListItemCollectionPosition -ne $null)

    $SPWeb.Dispose()

}