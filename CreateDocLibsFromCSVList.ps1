<#
Title: Create document libraries from CSV list
Author: Luke Brunning
Category: SharePoint EDRMS Scripts
Description
This script takes a CSV file of Titles and Descriptions and makes document libraries
#>

param(
    [string]$csv,
    [string]$url
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