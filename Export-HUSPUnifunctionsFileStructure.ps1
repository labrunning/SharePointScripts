<#
    .Synopsis
     Gets a list of document libraries
    .DESCRIPTION
     Use this function to get a list of site document libraries in XML format
    .Parameter site
     The Site Collection to search.
    .Parameter output
     A path and filename for the resulting XML export file
    .OUTPUTS
     An XML file containing all details of the document libraries
    .EXAMPLE 
     Export-HUSPUnifunctionsFileStructure -site https://devunifunctions.hud.ac.uk -output E:\SPOutput\DOCLIBS.xml
      Get a list of all the document libraries in https://devunifunctions.hud.ac.uk and save to the E:\SPOutput\DOCLIBS.xml file
    .LINK
      http://get-spscripts.com/2011/01/export-and-importcreate-site-columns-in.html
      #>

      function Export-HUSPUnifunctionsFileStructure {

        # **THIS DOES NOT WORK FOR ME**

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$True,Position=1)]
            [string]$site,
            [Parameter(Mandatory=$True,Position=2)]
            [string]$output
            )

        $SPSite = Get-SPSite $site
        $xmlFilePath = $output

        ##Create Export Files
        New-Item $xmlFilePath -type file -force

        ##Export Site Columns to XML file

        Add-Content $xmlFilePath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"

        Add-Content $xmlFilePath "`n<SiteCollection Title=`"$SPSite.Title`">"
        ForEach ( $SPWeb in $SPSite.AllWebs ) {
            Add-Content $xmlFilePath "`t<Site Title=`"$SPWeb.Title`"/>"
            ForEach ( $SPList in $SPWeb.Lists | Where-Object { $_.Hidden -eq $False } ) {
            Add-Content $xmlFilePath "`t`t<DocumentLibrary title=`"$_.Title`" parentWebUrl=`"$_.ParentWebUrl`" firstUniqueAncestor=`"$_.FirstUniqueAncestor`"/>"
            }  
        Add-Content $xmlFilePath "`t</Site>"
        }
        Add-Content $xmlFilePath "</SiteCollection>"
    
    $SPWeb.Dispose()

    $SPSite.Dispose()

}