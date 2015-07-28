<#
.SYNOPSIS
Gets a list of site columns from a document in a list given the Document ID
.DESCRIPTION
A longer more detailed description of what the script does
.PARAMETER param
a description of a parameter
.EXAMPLE
To get a list of values from a particular site column; 

    Get-SPDocumentValues | Where-Object {$_."Display Name" -eq "Archived Metadata" }
.NOTES
Some notes about the script
.LINK
http://get-spscripts.com/2010/09/get-all-column-values-from-sharepoint.html
#>
function Get-SPDocumentValues {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$WebName,
        [Parameter(Mandatory=$true)]
        [string]$ListName,
        [Parameter(Mandatory=$true)]
        [string]$FileName    
    )
        
    $web = Get-SPWeb $WebName
    $list = $web.Lists[$ListName]
    [string]$queryString = $null 

    $queryString = "<Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>" + $FileName + "</Value></Eq></Where>"

    $query = New-Object Microsoft.SharePoint.SPQuery
    $query.Query = $queryString
    $item = $list.GetItems($query)[0] 

    $item.Fields | foreach {
        $fieldValues = @{
            "Display Name" = $_.Title
            "Internal Name" = $_.InternalName
            "Value" = $item[$_.InternalName]
        }
        New-Object PSObject -Property $fieldValues | Select @("Display Name","Internal Name","Value")
    }
    $web.Dispose()
}