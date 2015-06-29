<# 
Title: Create SharePoint Sites from CSV List
Author: Luke Brunning
Category: SharePoint EDRMS Project Scripts
Description
This is a script creates new SharePoint sites from a CSV list of sites that contain the URL, name and description of sites.
#>

# Add the SharePoint snapin
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

# Set the path of the CSV to use
$SitesFile = Import-Csv -Path "D:\scripts\SiteListTest001.csv"
$SitesList = $SitesFile

# Confirm the number of sites to be created
Write-Host You are about to create the following sites;
$SitesList
$confirmation = Read-Host "Are you Sure You Want To Proceed: (press 'y' to proceed)"

# Loop through all the sites in the list
if ($confirmation -eq 'y') {
    # Create each site in the list
    ForEach ($site in $SitesList) {
        $SiteCollection = "https://devunishare.hud.ac.uk/unifunctions/Test/"
        $SiteURL = $SiteCollection + $site.URL
        New-SPWeb -Url $SiteURL -Name $site.Name -Description $site.Description -Template "BDR#0" -UniquePermissions | Out-Null
        $currentWeb = Get-SPWeb $newWebUrl
        # Set the locale
        $culture=[System.Globalization.CultureInfo]::CreateSpecificCulture(“en-UK”) 
        $currentWeb.Locale=$culture 
        # Enable Tree View
        $currentWeb.TreeViewEnabled = "True"
        $currentWeb.Update()
        # Enable site features
        $myFeatures = @("DocumentRouting","Hold","WorkflowAppOnlyPolicyManager")
        ForEach ($ft in $myFeatures) { Enable-SPFeature -Identity $ft -Url $currentWeb }
        Write-Host "Created site "$currentWeb.Title" at "$currentWeb.Url 
        $currentWeb.Dispose()
    }
}