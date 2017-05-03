<#
    ################################################################
    .Synopsis
     Runs a CAML query returning the fields specified as a parameter
    .DESCRIPTION
     Runs a CAML query specified by a vald XML CAML query file. By default only the number of items matching the query are returned.
     Use the -Verbose parameter to return the fields specified as a paramater with -fields. If none are supplied, then Id and Title are returned. 
    .Parameter url
     A valid SharePoint site url
    .Parameter list
     A valid SharePoint list
    .Parameter caml
     A file path to a valid SharePoint CAML query file
    .Parameter fields
     An array of list fields you want returned when using the verbose parameter
    .OUTPUTS
     Outputs a list of items matching the query, and if more than one is returned, an output object of that list title
    .EXAMPLE
     An example of the command in use;

        Test-HUSPCamlQuery -url $mySPWeb.Url -list $_.Title -caml .\scripts\xml\caml_nulldates.xml

    You can pipe this out to a variable to use with another command;

        $myNullDateComs = $mySPWeb.Lists | Where-Object {$_.Hidden -eq $false -and $_.Title -notlike "@*"} | % { Test-HUSPCamlQuery -url $mySPWeb.Url -list $_.Title -caml .\scripts\xml\caml_nulldates.xml}
    ################################################################
#>

function Test-HUSPCamlQuery {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$caml,
        [Parameter(Mandatory=$False,Position=4)]
        [string[]]$fields=@("ID","Title")
    )
    
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    
    $spQuery = New-Object Microsoft.SharePoint.SPQuery
    $spQuery.ViewAttributes = 'Scope="RecursiveAll"'
    $camlQuery = Get-Content $caml -Raw
    $spQuery.RowLimit = 100
    $spQuery.Query = $camlQuery
    
    do {
        $SPListItems = $SPList.GetItems($spQuery)
        $SPQueryCount += $SPListItems.Count
        $spQuery.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        $spDataTable = $SPListItems.GetDataTable()
    } while ($spQuery.ListItemCollectionPosition -ne $null)

    if ($SPQueryCount -ne 0) {
        $SPTestQueryObject = New-Object -TypeName PSObject
        $SPTestQueryObject | Add-Member -MemberType NoteProperty -Name ListTitle -Value $SPList.Title
        $SPTestQueryObject | Add-Member -MemberType NoteProperty -Name QueryCount -Value $SPQueryCount
        Write-Output $SPTestQueryObject
    } else {
        Write-Verbose "No results returned for $SPList.Title"
    }

    $SPWeb.Dispose()
}