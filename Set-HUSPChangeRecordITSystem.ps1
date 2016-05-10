<#
    .Synopsis
     Copies the IT System in the free text field 'System' to the dropdown options list
    .DESCRIPTION
     Takes the value in the System free text field and then copies this to the dropdown in the IT System field; does nothing if the System field is blank
    .Parameter url
      A valid SharePoint url
    .Parameter list
      A valid SharePoint list
    .Parameter lookup
      A valid SharePoint list that you want to use for the lookup
    .OUTPUTS
      Sets IT System 
    .EXAMPLE 
      Set-HUSPChangeRecordITSystem -url https://unishare.hud.ac.uk/cls/teams/it -list "Change Record database"
      Sets all the IT System dropdown field values to the same as the text only ones in 'System'
    .LINK
      A link (usually a link to where I stoled the script from)
#>  

function Set-HUSPChangeRecordITSystem {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$list
    )
        
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPListItems = $SPList.Items

    ForEach ($Item In $SPListItems ) {
        $ITSystem = $Item["System"].Trim()
        $SPLookupField = $SPList.Fields["IT System"] -as [Microsoft.SharePoint.SPFieldLookup]
        $SPLookupList = $SPWeb.Lists[[Guid]$SPLookupField.LookupList]
        $SPSourceField = $SPLookupField.LookupField
        $SPLookupItem = $SPLookupList.Items | Where-Object {$_.Name -eq $ITSystem }
        $SPLookupString = ($SPLookupItem.ID).ToString() + ";#" + ($SPLookupItem.Name).ToString()
        Write-Host Setting IT System to $SPLookupString on $Item["ID"]
        $Item["IT System"] = $SPLookupString
        $Item.SystemUpdate($false)
    }

    $SPWeb.Dispose()
}  