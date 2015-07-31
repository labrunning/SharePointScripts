<#
.SYNOPSIS
A script to undelcare all records in a list
.DESCRIPTION
This script takes a Site Url and a List name and undeclares any records in that list
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
function Set-AllRecordsUndeclared {
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$True,Position=1)]
      [string]$url,
      [Parameter(Mandatory=$True)]
      [string]$list
    )

    $SPAssignment = Start-SPAssignment
    $web = Get-SPWeb $url -AssignmentCollection $spAssignment
    $list = $web.lists[$list].items
    foreach ($item in $list) {
        $IsRecord = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::IsRecord($Item)
        if ($IsRecord -eq $true) {
            # Write-Verbose "Undeclared $($item.Title)"
            [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::UndeclareItemAsRecord($Item)
        }
    }
    Stop-SPAssignment $SPAssignment
}