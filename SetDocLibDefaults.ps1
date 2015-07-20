<#
Title: Set document library defaults
Author: Luke Brunning
Category: SharePoint EDRMS Scripts
Description
This script takes a CSV file of Titles and Descriptions and makes document libraries
#>

param(
    [string]$url
    )

if(-not($url)) { throw "You must enter a value for -url"}

# Add the SharePoint snapin
if ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }


$spWeb = Get-SPWeb $url

foreach($docLib in $spWeb.Lists)
{
    if( ($docLib.BaseType -eq "DocumentLibrary") -and ($docLib.Hidden -eq $false) )
    $docLib.OnQuickLaunch = $false
    $docLib.EnableVersioning = $true
    $docLib.EnableModeration = $false
    $docLib.EnableMinorVersions = $true
    $docLib.ForceCheckOut = $false
    $docLib.EnableFolderCreation = $false
    $docLib.ContentTypesEnabled = $true
    $docLib.Update()
}

$spWeb.Dispose()