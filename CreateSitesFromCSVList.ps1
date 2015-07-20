<# 
Title: Create SharePoint Sites from CSV List
Author: Luke Brunning
Category: SharePoint EDRMS Project Scripts
Description
This is a script creates new SharePoint sites from a CSV list of sites that contain the URL, name and description of sites.
#>

Param(
    [string]$csv,
    [string]$url
    )

if(-not($csv)) { Throw "You must enter a value for -csv"}

if(-not($url)) { Throw "You must enter a value for -url"}

# Add the SharePoint snapin
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

# Set the path of the CSV to use
$SitesFile = Import-Csv -Path "$csv"
$SitesList = $SitesFile

# Confirm the number of sites to be created
Write-Host You are about to create the following sites;
$SitesList
$confirmation = Read-Host "Are you Sure You Want To Proceed: (press 'y' to proceed)"

# Loop through all the sites in the list
if ($confirmation -eq 'y') {
    # Create each site in the list
    ForEach ($site in $SitesList) {
        $SiteCollection = "$url"
        $SiteURL = $SiteCollection + $site.URL
        New-SPWeb -Url $SiteURL -Name $site.Name -Description $site.Description -Template "BDR#0" -UniquePermissions | Out-Null
        $currentWeb = Get-SPWeb $SiteURL
        # Set the locale
        $culture=[System.Globalization.CultureInfo]::CreateSpecificCulture(“en-UK”) 
        $currentWeb.Locale=$culture 
        # Enable Tree View
        $currentWeb.TreeViewEnabled = $true
        # turn off quick launch?
        $currentWeb.Update()
        Write-Host "Created site"$currentWeb.Title"at"$currentWeb.Url 
        $currentWeb.Dispose()
    }
}