$sitelogo="https://testunishare.hud.ac.uk/images/siteIconLogoSPEDRMS.png"
$Site="https://testunishare.hud.ac.uk"
$Sites=Get-SPWebApplication $Site | Get-SPSite -Limit All | Get-SPWeb -Limit All | Select URL
$Sites | ForEach-Object {
	$CurrentSite=$_.URL
	$CurrentSiteObject=new-object Microsoft.SharePoint.SPSite($CurrentSite)
	foreach($web in $CurrentSiteObject.Allwebs) {
		$web.SiteLogoUrl=$sitelogo
		$web.Update()
	}
	$CurrentSiteObject.Dispose()
}