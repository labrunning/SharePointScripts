$siteUrl = "https://devunishare.hud.ac.uk/"
 
$rootSite = New-Object Microsoft.SharePoint.SPSite($siteUrl)
$spWebApp = $rootSite.WebApplication
 
foreach($site in $spWebApp.Sites)
{
    $MySiteCollectionTitle = $site.Title
    Write-Output $MySiteCollectionTitle
    foreach($siteAdmin in $site.RootWeb.SiteAdministrators)
    {
        Write-Output "$($siteAdmin.ParentWeb.Url) - $($siteAdmin.DisplayName)"
    }
    $site.Dispose()
}
$rootSite.Dispose()