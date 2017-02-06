<#
    .SYNOPSIS
     Gets a list of site columns from a document in a list given the Document ID
    .DESCRIPTION
     This script outputs the values of a list as a powershell object that can then be piped to other powershell commands (see example)
    .PARAMETER url
     a valid SharePoint site url
    .PARAMETER list
     a valid SharePoint list name
    .PARAMETER file
     a valid SharePoint document filename (optional)
    .EXAMPLE
     Get-HUSPDocumentValues -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -list "University Health and Safety Committee" | Where-Object {$_."Display Name" -eq "Archived Metadata" }
#>

function Get-HUSPDocumentValuesCaml {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$true,Position=3)]
        [String]$caml
    )
    
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

        $spQuery = New-Object Microsoft.SharePoint.SPQuery
        $spQuery.Query = $caml

        do {
            $SPListItems = $SPList.GetItems($spQuery)
            $spQuery.ListItemCollectionPosition = $SPListItems.ListItemCollection
            ForEach($SPItem in $SPListItems) {
                $SPItemId = $SPItem['_dlc_DocId'].ToString()
                $SPItem.Fields | foreach {
                    $SPFieldValues = @{
                        "Display Name" = $_.Title
                        "Internal Name" = $_.InternalName
                        "Value" = $SPItem[$_.InternalName]
                    }
                    New-Object PSObject -Property $SPFieldValues | Select @("Display Name","Internal Name","Value")
                }
                Write-Host "----====++++End Item: $SPItemId ++++====----"
            }
        }  while ($null -ne $spQuery.ListItemCollectionPosition)
    $SPWeb.Dispose()
}