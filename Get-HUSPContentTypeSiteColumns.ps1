<# 
    ################################################################
    #.Synopsis
    # Script to export to an XML file all the site columns in a content type
    #.DESCRIPTION
    # This script will export all the site column data from a named content type to an XML file
    #.Parameter url
    #  A valid SharePoint Url where the content type can be found
    #.Parameter ct
    #  A valid SharePoint content type
    #.Parameter xml
    #  A filename to use to output the XML to
    #.OUTPUTS
    #  Outputs an XML file with the site columns in
    #.EXAMPLE 
    #  My-Script -url -ct
    #  Does what the script does
    #.LINK
    #  http://get-spscripts.com/2011/01/export-and-importcreate-site-columns-in.html
    ################################################################
#>    

$sourceWeb = Get-SPWeb https://unishare.hud.ac.uk/Unifunctions
$GroupName = "EDRMS Content Types"
$xmlFilePath = "D:\SPOutput\" + $GroupName + ".xml"

#Create Export Files
New-Item $xmlFilePath -type file -force

#Export Site Columns to XML file
Add-Content $xmlFilePath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
Add-Content $xmlFilePath "<ContentTypes>"
$sourceWeb.ContentTypes | ForEach-Object {
    if ($_.Group -eq $GroupName) {
        Add-Content $xmlFilePath $_.SchemaXml
    }
}
Add-Content $xmlFilePath "</ContentTypes>"

# Output to a powershell object which will allow manipulation of the output via powershell

$sourceWeb.Dispose()
