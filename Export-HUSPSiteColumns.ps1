<#
    .Synopsis
     Gets a list of site columns in XML format
    .DESCRIPTION
     Use this function to get a list of site columns in XML format which you can then use to import into a new site collection
    .Parameter web
      The Web Application to search.
    .Parameter output
      A path and filename for the resulting XML export file
    .Parameter group
      The group name of the site columns you want to export
    .OUTPUTS
      An XML file containing all details of the site columns in a site column group which can be imported into a new site collection
    .EXAMPLE 
      Export-HUSPSiteColumns -web https://devunishare.hud.ac.uk -output ..\SPOutput\EDRMSDefault.xml -group "EDRMS Default"
      Get a list of all the site columns in the "EDRMS Group" in https://devunishare.hud.ac.uk and save to the ..\SPOutput\EDRMSDefault.xml file
    .LINK
      http://get-spscripts.com/2011/01/export-and-importcreate-site-columns-in.html
#>

function Export-HUSPSiteColumns {

    # **THIS DOES NOT WORK FOR ME**

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$web,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$output,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$group
    )

    $sourceWeb = Get-SPWeb $web
    $xmlFilePath = $output
    
    #Create Export Files
    New-Item $xmlFilePath -type file -force
    
    #Export Site Columns to XML file
    Add-Content $xmlFilePath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
    Add-Content $xmlFilePath "`n<Fields>"
    $sourceWeb.Fields | ForEach-Object {
        if ($_.Group -eq $group) {
            Add-Content $xmlFilePath $_.SchemaXml
        }
    }
    Add-Content $xmlFilePath "</Fields>"

    $sourceWeb.Dispose()
}