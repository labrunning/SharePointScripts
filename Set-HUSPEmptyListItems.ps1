<# 
    .Synopsis
     Applies only to empty list items
    .DESCRIPTION
     For a given list this script will apply only to empty items
    .Parameter url
      A valid SharePoint list url
    .Parameter list
      A valid SharePoint list name
    .Parameter field
      A valid SharePoint Field
    .OUTPUTS
      All the empty field items
    .EXAMPLE 
      Set-HUSPEmptyListItems -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee" -field "University Committee Name"
      Does what the script does
    .LINK
      A link (usually a link to where I stoled the script from)
#>

function Set-HUSPEmptyListItems {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=1)]
        [string]$url="https://unishare.hud.ac.uk/unifunctions/COM/Computing-and-Library-Services",
        [Parameter(Mandatory=$false,Position=2)]
        [string]$list="Record Administrator Meeting",
        [Parameter(Mandatory=$false,Position=3)]
        [string]$field="CLS Committee Name"
    )
    
    #Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPListItems = $SPList.Items
    $docLib = $SPWeb.Lists[$list]

    $SPWeb.AllowUnsafeUpdates = $true
    
    foreach($item in $SPListItems | where {$_[$field] -eq $null} ) {
        $CurrentRecord = $item['_dlc_DocId'].ToString()
        Write-Output "Checking" $CurrentRecord
        If ($item[$field] -eq $null) {
            Write-Output $CurrentRecord "has a null field"
        } else {
            Write-Output "Field check passed:" $item[$field]
        }
    }
    
    $SPWeb.AllowUnsafeUpdates = $false
    $SPWeb.Dispose()
}