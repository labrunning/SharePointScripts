<#
    .SYNOPSIS
    A script to undelcare all records in a list
    .DESCRIPTION
    This script takes a Site Url and a List name and undeclares any records in that list and also sets the 'Allow Deletion' property to true.
    .PARAMETER url
    a valid SharePoint Site Url
    .PARAMETER list
    a valid SharePoint List name
    .EXAMPLE
    Set-AllRecordsUndeclared -url https://devunishare.hud.ac.uk/unifunctions/university-committees -list 'University Health and Safety Committee'
    .NOTES
    .LINK
    http://www.mysharepointadventures.com/2012/06/undeclare-declare-all-some-records-in-a-list/
#>
function Set-HUSPRecordsUndeclared {
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
    ForEach ($Item In $SPListItems) {
        $IsRecord = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::IsRecord($Item)
        If ($IsRecord -eq $true) {
            $CurrentRecord = $Item.Name
            Write-Verbose "Undeclared $CurrentRecord"
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::UndeclareItemAsRecord($Item)
        }
    }
    $SPList.AllowDeletion = $true
    $SPList.Update()
    $SPWeb.Dispose()
}