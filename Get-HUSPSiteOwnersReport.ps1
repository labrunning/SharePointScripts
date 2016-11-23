<#
    ################################################################
    .Synopsis
     Creates an XML report of all groups with full control in a web application
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter url
     A description of the url parameter
    .Parameter list
     A description of the url parameter
    .OUTPUTS
     A description of what the script outputs
    .EXAMPLE 
     An example of the command in use
    ################################################################
#>
    
function Get-HUSPSiteOwnersReport {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        # The URL must have a trailing slash!    
        [string]$webapp
    )

    $xmlPath = "$((pwd).path)/HUSPSiteOwnersReport.xml"
    $resultInXml = new-object xml
    $decl = $resultInXml.CreateXmlDeclaration("1.0", $null, $null)
    $rootNode = $resultInXml.CreateElement("PermissionsReport")
    $resultInXml.InsertBefore($decl, $resultInXml.DocumentElement)
    $resultInXml.AppendChild($rootNode)

    # Get all the websites in the web application
    $SPSites = Get-SPSite -WebApplication $webapp -Limit ALL

    $SPfarm = [Microsoft.SharePoint.Administration.SPFarm]::get_Local()

    #WEB APPLICATION ENTITY
    $SPWebAppElem = $resultInXml.CreateElement("WebApplication")
    $SPWebAppElem.SetAttribute("ID", $SPFarm.Id )
    $rootNode.AppendChild($SPWebAppElem)

    #SITE COLLECTIONS ENTITY
    $SPSitesElem= $resultInXml.CreateElement("SiteCollections")
    $SPWebAppElem.AppendChild($SPSitesElem)
    
    ForEach ( $SPSite in $SPSites ) {
        $SPSiteElem = $resultInXml.CreateElement("SiteCollection")
        $SPSiteElem.SetAttribute("Url", $SPSite.Url)
        $SPSitesElem.AppendChild($SPSiteElem)
        
        #SITE COLLECTIONS ENTITY
        $SPWebsElem= $resultInXml.CreateElement("WebSites")
        $SPSitesElem.AppendChild($SPWebsElem)    
        
        ForEach ( $SPWeb in $SPSite.AllWebs ) {
            $SPWebElem = $resultInXml.CreateElement("WebSite")
            $SPWebElem.SetAttribute("Name", $SPWeb.Name)
            $SPWebElem.SetAttribute("Url", $SPWeb.Url)
            $SPWebElem.SetAttribute("RootWeb", $SPWeb.IsRootWeb)
            $SPWebElem.SetAttribute("HasUniquePerm", $SPWeb.HasUniquePerm)
            $SPWebElem.SetAttribute("HasUniqueRoleAssignments", $SPWeb.HasUniqueRoleAssignments)
            $SPWebsElem.AppendChild($SPWebElem)  

            # GROUP COLLECTIONS ENTITY
            $SPGroupsElem= $resultInXml.CreateElement("Groups")
            $SPWebsElem.AppendChild($SPGroupsElem)

            ForEach ( $Group in $SPWeb.Groups ) {
                $SPGroupElem = $resultInXml.CreateElement("Group")
                $SPGroupElem.SetAttribute("Name", $Group.Name)

                # ROLES ENTITY
                $SPRolesElem= $resultInXml.CreateElement("Roles")
                $SPGroupElem.AppendChild($SPRolesElem)

                ForEach ( $Role in $SPGroup.Roles ) {
                    $SPRoleElem = $resultInXml.CreateElement("Role")
                    $SPRoleElem.SetAttribute("Name", $Role.Name) # FIX ME - role names not being listed
                    $SPRolesElem.AppendChild($SPRoleElem)
                }

                # USERS ENTITY
                $SPUsersElem= $resultInXml.CreateElement("Users")

                ForEach ( $User in $Group.Users ) {
                    $SPUserElem = $resultInXml.CreateElement("User")
                    $SPUserElem.SetAttribute("DisplayName", $User.DisplayName)
                    $SPUsersElem.AppendChild($SPUserElem)
                }
                
                $SPGroupElem.AppendChild($SPUsersElem)
                
                $SPGroupsElem.AppendChild($SPGroupElem)   
            }

            $SPWeb.Dispose()   
        }

        $SPSite.Dispose() 
    }

    $SPSites.Dispose()

    #Output
    $resultInXml.Save($xmlPath)
    ""

}