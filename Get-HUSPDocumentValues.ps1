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
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [int]$Id
    )
    
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

    $IdPresent = $PSBoundParameters.ContainsKey('id') 

    If ($IdPresent -eq $false) {
        Write-Verbose "No specified file"
        $FullList = $SPList.GetItems()
        ForEach ($item in $FullList) {
            $item.Fields | foreach {
                $fieldValues = @{
                    "Display Name" = $_.Title
                    "Internal Name" = $_.InternalName
                    "Value" = $item[$_.InternalName]
                }
                New-Object PSObject -Property $fieldValues | Select @("Display Name","Internal Name","Value")
            }            
            Write-Output "+++------------------------------------------------------+++"
        }
    } else {
        Write-Verbose "Id '$Id' specified"
        [string]$queryString = $null 
        $queryString = "<Where><Eq><FieldRef Name='ID' /><Value Type='Counter'>" + $Id + "</Value></Eq></Where>"
        $query = New-Object Microsoft.SharePoint.SPQuery
        $query.Query = $queryString
        $item = $SPList.GetItems($query)[0] 
        
        $item.Fields | foreach {
            $fieldValues = @{
                "Display Name" = $_.Title
                "Internal Name" = $_.InternalName
                "Value" = $item[$_.InternalName]
            }
            New-Object PSObject -Property $fieldValues | Select @("Display Name","Internal Name","Value")
        }
    }
    $SPWeb.Dispose()
}