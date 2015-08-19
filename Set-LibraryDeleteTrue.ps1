<#
.SYNOPSIS
Sets the delete library option to true
.DESCRIPTION
Sometimes a document library does not have the option to delete it available, this function will enable it
.PARAMETER url
a valid SharePoint Url
.PARAMETER list
a valid SharePoint list name
.EXAMPLE
Set-LibraryDeleteTrue -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -list 'University Health and Safety Committee'
#>

function Set-LibraryDeleteTrue {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$list
    )
    $web = Get-SPWeb $url
    $doclist = $web.Lists[$list]
    $doclist.AllowDeletion = $true
    $doclist.Update()
    $web.Dispose()
}