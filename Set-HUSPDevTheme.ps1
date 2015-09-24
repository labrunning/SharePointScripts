$themeName = "MyDevTheme"
$SPSite = Get-SPSite "https://devunishare.hud.ac.uk/"    
foreach ($SPWeb in $SPSite.AllWebs) 
{ 
    $SPWeb.allowunsafeupdates = $true
    $fontSchemeUrl = Out-Null
    $imageUrl = Out-Null
    $SPWeb.ApplyTheme("/_catalogs/theme/15/Palette012.spcolor", $fontSchemeUrl, $imageUrl, $true);
    Write-Host "Set" $themeName "at :" $SPWeb.Title "(" $SPWeb.Url ")"
    $SPWeb.SiteLogoUrl = "/_layouts/15/images/siteIcon-SPDEV001.jpg"
    $SPWeb.Update()
    $SPWeb.allowunsafeupdates = $false
    $SPWeb.Dispose()
}  
$SPSite.Dispose()