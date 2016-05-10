function Get-HUSPSite([string]$url) {
  $SPSite = Get-SPSite $url
  return $SPSite.OpenWeb()
  $SPSite.Dispose()
}

function Get-HUSPWebApplications {
  $SPWebApplicationCollection = Get-SPWebApplication -IncludeCentralAdministration
  return $SPWebApplicationCollection
}

function Get-HUSPAdminWebApplication {
  $SPWebApplicationCollection = Get-HUSPWebApplications
  foreach ($SPWebApplication in $SPWebApplicationCollection) {
    if ($SPWebApplication.IsAdministrationWebApplication) {
      $adminWebapp = $SPWebApplication
  }
}
return $adminWebApp
}

function Get-HUSPfarmAdministrators {
  $admin = Get-HUSPAdminWebApplication
  foreach ($adminsite in $admin.Sites) {
    $adminWeb = Get-HUSPSite($adminsite.url)
    $AdminGroupName = $adminWeb.AssociatedOwnerGroup
    $farmAdministratorsGroup = $adminweb.SiteGroups[$AdminGroupName]
    return $farmAdministratorsGroup.users
}
}

function Get-ALLSiteCollectionAdminstrators {
  $spWebApps = Get-HUSPWebApplications
  foreach ($spWebApp in $spWebApps) {
    #WEB APPLICATION ENTITY
    $WebAppElem= $resultInXml.CreateElement("WebApplication")
    $WebAppElem.SetAttribute("Url", $spWebApp.Url);
    $WebAppsElem.AppendChild($WebAppElem);
    #SITE COLLECTIONS ENTITY
    $SiteCollsElem= $resultInXml.CreateElement("SiteCollections")
    $WebAppElem.AppendChild($SiteCollsElem);
    foreach($site in $spWebApp.Sites) {
      #SITE COLLECTION ENTITY
      $SiteCollElem= $resultInXml.CreateElement("SiteCollection")
      $SiteCollElem.SetAttribute("Url", $site.Url);
      $SiteCollsElem.AppendChild($SiteCollElem);   
      #SITE COLLECTION ADMINISTRATORS ENTITY
      $SiteCollAdmsElem= $resultInXml.CreateElement("SiteCollectionAdministrators")
      $SiteCollElem.AppendChild($SiteCollAdmsElem);   
      foreach($siteAdmin in $site.RootWeb.SiteAdministrators) {
        #SITE COLLECTION ADMINISTRATOR ENTITY
        $SiteCollAdmElem= $resultInXml.CreateElement("SiteCollectionAdministrator")
        $SiteCollAdmElem.SetAttribute("UserLogin",$siteAdmin.UserLogin)
        $SiteCollAdmElem.SetAttribute("DisplayName",$siteAdmin.DisplayName)
        $SiteCollAdmsElem.AppendChild($SiteCollAdmElem); 
        Write-Verbose "$($siteAdmin.ParentWeb.Url) - $($siteAdmin.DisplayName)"
    }
    $site.Dispose()
}
}
}

####################
#  MAIN
####################

$xmlPath = "$((pwd).path)/SPAdministratorsReport.xml";

$SPfarm = [Microsoft.SharePoint.Administration.SPFarm]::get_Local()

$resultInXml = new-object xml
$decl = $resultInXml.CreateXmlDeclaration("1.0", $null, $null)
$rootNode = $resultInXml.CreateElement("AdministratorsReport");
$resultInXml.InsertBefore($decl, $resultInXml.DocumentElement)
$resultInXml.AppendChild($rootNode);

#FARM ENTITY
$farmElem = $resultInXml.CreateElement("Farm")
$farmElem.SetAttribute("ID", $SPfarm.Id );
$rootNode.AppendChild($farmElem);

#FARM ADMINISTRATORS ENTITY
$farmAdminsElem= $resultInXml.CreateElement("FarmAdministrators")
$farmElem.AppendChild($farmAdminsElem);

$farmAdmins = Get-HUSPfarmAdministrators

foreach ($farmAdmin in $farmAdmins) {
  $farmAdminElem = $resultInXml.CreateElement("FarmAdmin")
  $farmAdminElem.SetAttribute("UserLogin",$farmAdmin.UserLogin)
  $farmAdminElem.SetAttribute("DisplayName",$farmAdmin.DisplayName)
  $farmAdminsElem.AppendChild($farmAdminElem);
}

#WEB APPLICATIONS ENTITY
$WebAppsElem= $resultInXml.CreateElement("WebApplications")
$farmElem.AppendChild($WebAppsElem);

#WEB APPLICATION ENTITY
Get-ALLSiteCollectionAdminstrators

#Output
$resultInXml.Save($xmlPath)
""
## Upload to the SiteAssets folder in SP

# Set the variables 
$WebURL = "https://unishare.hud.ac.uk/help"
$DocLibName = "SiteAssets"
$FilePath = $xmlPath

# Get a variable that points to the folder 
$Web = Get-SPWeb $WebURL 
$List = $Web.GetFolder($DocLibName) 
$Files = $List.Files

# Get just the name of the file from the whole path 
$FileName = "SPAdministratorsReport.xml"

# Load the file into a variable 
$File= Get-ChildItem $FilePath

# Upload it to SharePoint 
$Files.Add($DocLibName +"/" + $FileName,$File.OpenRead(),$true) 
$web.Dispose()