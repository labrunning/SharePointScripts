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

function Get-HUSPDocumentValues {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$false,Position=3)]
        [AllowEmptyString()]
        [String]$caml
    )
    
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

    $CamlPresent = $PSBoundParameters.ContainsKey('caml') 

    If ($CamlPresent -eq $false) {
        Write-Host "No CAML query specified, getting all values..."
        $SPFullList = $SPList.GetItems()
        ForEach ($SPItem in $SPFullList) {
            $SPItemId = $SPItem['_dlc_DocId'].ToString()
            $SPItem.Fields | foreach {
                $SPFieldValues = @{
                    "Display Name" = $_.Title
                    "Internal Name" = $_.InternalName
                    "Value" = $SPItem[$_.InternalName]
                }
                New-Object PSObject -Property $SPFieldValues | Select @("Display Name","Internal Name","Value")
            }            
            Write-Host "----====++++End Item: $SPItemId ++++====----" -ForegroundColor Cyan
        }
    } else {
        Write-Host "CAML query provided..."
        $spQuery = New-Object Microsoft.SharePoint.SPQuery
        $camlQuery = Get-Content $caml -Raw
        $spQuery.Query = $camlQuery

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
    }
    $SPWeb.Dispose()
}