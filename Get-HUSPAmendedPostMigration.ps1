<#
    .SYNOPSIS
    A script to determine if a file has archived metadata
    .DESCRIPTION
    This script takes a Site Url and a List name and an optional Id and states if there is any archived metadata
    .PARAMETER url
    a valid SharePoint Site Url
    .PARAMETER list
    a valid SharePoint List name
    .PARAMETER Id
    a valid SharePoint List Item Id
    .EXAMPLE
    Get-HUSPAmendedPostMigration -url https://unifunctions.hud.ac.uk/COM/University-Committees -list 'University Health and Safety Committee' -Id 1
#>

function Get-HUSPAmendedPostMigration {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [int]$Id
    )

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

    Write-Host Checking $SPList

    $IdPresent = $PSBoundParameters.ContainsKey('id')

    If ($IdPresent -eq $false) {
        $SPItems = $SPList.GetItems()
        ForEach ($SPItem in $SPItems) {    
            $SPItem.Fields["Archived Metadata"] | ForEach {
                If ( $SPItem[$_.InternalName] -eq $null ) {
                    Write-Host There is no archived Metadata for item ID $SPItem['_dlc_DocId'] it was created on $SPItem['Created']
                } else {    
                    # Write-Host There is Archived Metadata for item ID $SPItem['_dlc_DocId']
                    # $SPItem[$_.InternalName]
                }
            }
        }
    } else {
        [string]$queryString = $null 
        $queryString = "<Where><Eq><FieldRef Name='ID' /><Value Type='Counter'>" + $Id + "</Value></Eq></Where>"
        $query = New-Object Microsoft.SharePoint.SPQuery
        $query.Query = $queryString
        $SPItem = $SPList.GetItems($query)[0] 
        $SPItem.Fields["Archived Metadata"] | ForEach {
            If ( $SPItem[$_.InternalName] -eq $null ) {
                Write-Host There is no archived Metadata for item ID $SPItem['_dlc_DocId'] it was created on $SPItem['CreatedDate']
            } else {    
                # Write-Host There is Archived Metadata for item ID $SPItem['_dlc_DocId']
                # $SPItem[$_.InternalName]
            }
        }             
    }

    $SPWeb.Dispose()
}