<#
.SYNOPSIS
Creates a number of document libraries from a CSV list
.DESCRIPTION
This script will create a number of document libraries from a valid CSV file which contains the titles and descriptions for each of the document libraries. There must be a title for each document library but there does not need to be a description.
.PARAMETER url
a valid SharePoint Site Url
.PARAMETER csv
a valid CSV file
.EXAMPLE
Set-DocumentLibraries.ps1 -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -csv .\DocLibList.csv
#>
param(
    [string]$url,
    [string]$csv
    )

if(-not($csv)) { throw "You must enter a value for -csv"}

if(-not($url)) { throw "You must enter a value for -url"}

# Add the SharePoint snapin
if ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

# Set the path of the CSV to use
$docList = Import-Csv -Path "$csv"
$libList = $docList

# Confirm the document libraries to be created
Write-Host You are about to create the following sites;
$libList
$confirmation = Read-Host "Are you sure you want to proceeed? (press 'y' to proceed)"

# Loop through all the document libraries in the list
if ($confirmation -eq 'y') {
    $siteUrl = "$url"
    $spWeb = Get-SPWeb $siteUrl
    $listTemplate = [Microsoft.SharePoint.SPListTemplateType]::DocumentLibrary 
    foreach ($docLib in $libList) {
        $spWeb.Lists.Add($docLib.Title,$docLib.Description,$listTemplate)
    }
    $spWeb.Dispose()
}