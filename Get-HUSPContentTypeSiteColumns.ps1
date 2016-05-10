<# 
    .Synopsis
     Script to export to an XML file all the site columns in a content type
    .DESCRIPTION
     This script will export all the site column data from a named content type to an XML file
    .Parameter url
      A valid SharePoint Url where the content type can be found (for example a content type hub!O)
    .Parameter group
      A valid SharePoint content type group name
    .Parameter path
      A folder to use to output the XML to (the group name will be used) i.e. "D:\SPOutput\"
    .OUTPUTS
      Outputs an XML file with the site columns in
    .EXAMPLE 
      My-Script -url -ct
      Does what the script does
    .LINK
      http://get-spscripts.com/2011/01/export-and-importcreate-site-columns-in.html
#>    

function Get-HUSPContentTypeSiteColumns {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$group,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$path
    )
    
    $SPWeb = Get-SPWeb $url
    $GroupName = $group
    $xmlFilePath = $path + $GroupName + ".xml"
    
    #Create Export Files
    New-Item $xmlFilePath -type file -force
    
    #Export Site Columns to XML file
    Add-Content $xmlFilePath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
    Add-Content $xmlFilePath "<ContentTypes>"
    $SPWeb.ContentTypes | ForEach-Object {
        If ($_.Group -eq $GroupName) {
            Add-Content $xmlFilePath $_.SchemaXml
        }
    }
    Add-Content $xmlFilePath "</ContentTypes>"
    
    $SPWeb.Dispose()
}