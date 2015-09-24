$themeName = "UoHEDRMS"
$SPSite = Get-SPSite "https://testunishare.hud.ac.uk/unifunctions"    
foreach ($SPWeb in $SPSite.AllWebs) 
{
    $SPWeb.allowunsafeupdates = $true
    $fontSchemeUrl = Out-Null
    $themeUrl = [Microsoft.SharePoint.Utilities.SPUrlUtility]::CombineUrl($SPSite.ServerRelativeUrl, "/_catalogs/theme/15/UoHColours.spcolor")
    $imageUrl = [Microsoft.SharePoint.Utilities.SPUrlUtility]::CombineUrl($SPSite.ServerRelativeUrl, "/images/EDRMS_Background002.jpg")
    $SPWeb.ApplyTheme($themeUrl, $fontSchemeUrl, $imageUrl, $true);
    write-host $SPWeb.Title
    $SPWeb.allowunsafeupdates = $false
    $SPWeb.Dispose()
}  
$SPSite.Dispose()