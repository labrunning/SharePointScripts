# Change to my new function style..
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
#Report Date
$reportDate=(get-date -f dd/M/yyyy)
$filenameDate=(get-date -f yyyy-M-dd)
#Configure the location for the output file
$Output="D:\SPOutput\$filenameDate-SiteCollectionReport.csv";
"Site"+"`t"+"Report Type"+"`t"+"Report Date"+"`t"+"Value"+"`t"+"Max Value"+"`t"+"Full Site Name" | Out-File -Encoding Default -FilePath $Output;
#Specify the root site collection within the Web app
$Siteurl="https://unishare.hud.ac.uk";
$Rootweb=New-Object Microsoft.Sharepoint.Spsite($Siteurl);
$Webapp=$Rootweb.Webapplication;
#Loops through each site collection within the Web app
Foreach ($Site in $Webapp.Sites)
{if ($Site.Quota.Storagemaximumlevel -gt 0) {[int]$MaxStorage=$Site.Quota.StorageMaximumLevel /1MB} else {$MaxStorage="0"}; 
if ($Site.Usage.Storage -gt 0) {[int]$StorageUsed=$Site.Usage.Storage /1MB};
if ($Storageused-gt 0 -and $Maxstorage-gt 0){[int]$SiteQuotaUsed=$Storageused/$Maxstorage* 100} else {$SiteQuotaUsed="0"}; 
$Web=$Site.Rootweb; $Site.Url + "`tStorage Usage (MB)`t" + $reportDate + "`t" + $StorageUsed + "`t" +$MaxStorage + "`t" +$Site.RootWeb | Out-File -Encoding Default -Append -FilePath $Output;
$Web=$Site.Rootweb; $Site.Url + "`tNumber of Sites`t" + $reportDate + "`t" + $Site.AllWebs.Count + "`tN/A`t" +$Site.Rootweb | Out-File -Encoding Default -Append -FilePath $Output;
$Site.Dispose()};