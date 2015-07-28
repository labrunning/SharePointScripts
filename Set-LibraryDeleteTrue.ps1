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

function Set-LibraryDeleteTrue($url, $list) {
    $web = Get-SPWeb $url
    $list = $web.Lists[$list]
    $list.AllowDeletion = $true
    $list.Update()
    $web.Dispose()
}