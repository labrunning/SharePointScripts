<#
.SYNOPSIS
Creates SharePoint Sites from a list
.DESCRIPTION
Creates SharePoint Sites from a CSV list and a given url. The CSV file must have a header with the following column headings;
- Name
- Description
- URL
.PARAMETER url
a valid SharePoint Site URL where you want all the sites creating
.PARAMETER csv
a valid CSV file with the information about the sites to be created
.PARAMETER template
a valid SharePoint Template code (default is BDR#0 which is a Document Centre )
.EXAMPLE
An example of how the script can be used
.NOTES
Some notes about the script
.LINK
a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>
function New-SitesFromList {
    [CmdletBinding()]
        Param(
        [Parameter(Mandatory=$true,Position=1)]
        [alias("url")]
        [string[]]
        $urlPath,
        [Parameter(Mandatory=$true,Position=2)]
        [alias("csv")]
        [string[]]
        $csvFile,
        [Parameter(Mandatory=$false,Position=3)]
        [string]$SiteTemplate
        )
    
    Write-Verbose -Message "Importing list of sites from $csv"
    $SitesFile = Import-Csv -Path "$csvFile"
    $SitesList = $SitesFile
    
    Write-Verbose "You are about to create the following sites;"
    $SitesList
    $ConfirmCreateSites = Read-Host "Are you Sure You Want To Proceed: (press 'y' to proceed)"
    
    If ($SiteTemplate -eq $null) {
        Write-Verbose "Site template parameter is blank, setting to Document Centre"
        $SiteTemplate = "BDR#0"
    }

    If ($ConfirmCreateSites -eq 'y') {
        ForEach ($site in $SitesList) {
            $SiteCollection = "$urlPath"
            $SiteURL = $SiteCollection + $site.URL
            New-SPWeb -Url $SiteURL -Name $site.Name -Description $site.Description -Template $SiteTemplate -UniquePermissions | Out-Null
            $currentWeb = Get-SPWeb $SiteURL
            Write-Verbose -Message 'Set the locale to en-UK'
            $culture=[System.Globalization.CultureInfo]::CreateSpecificCulture(“en-UK”) 
            $currentWeb.Locale=$culture 
            Write-Verbose -Message 'Enabling Tree View...'
            $currentWeb.TreeViewEnabled = $true
            $currentWeb.Update()
            Write-Debug -Message "Created site $currentWeb.Title at $currentWeb.Url"
            $currentWeb.Dispose()
        }
    }
}