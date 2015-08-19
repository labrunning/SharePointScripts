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
    a valid SharePoint Template code (default is BDR#0 which is a Document Centre ); use Get-SPWebTemplate to see a full list
    .EXAMPLE
    An example of how the script can be used
    .NOTES
    When the sites are created, they are set to UK regional settings and Tree View is enabled. If you do not specify a template, the default will be used.
#>
function New-HUSPSitesFromList {
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true,Position=1)]
            [string]$url,
            [Parameter(Mandatory=$true,Position=2)]
            [string]$csv,
            [Parameter(Mandatory=$false,Position=3)]
            [string]$temp = "BDR#0"
        )
    
    Write-Debug "Site template is $temp"

    Write-Verbose -Message "Importing list of sites from $csv"
    $SitesList = Import-Csv -Path "$csv"
    
    Write-Verbose "You are about to create the following sites;"
    $SitesList
    $ConfirmCreateSites = Read-Host "Are you Sure You Want To Proceed: (press 'y' to proceed)"

    If ($ConfirmCreateSites -eq 'y') {
        ForEach ($site in $SitesList) {
            $SiteCollection = "$url"
            $SiteURL = $SiteCollection.TrimEnd("/") + "/" + $site.URL
            Write-Debug "Creating $SiteURL..."
            New-SPWeb -Url $SiteURL -Name $site.Name -Description $site.Description -Template $temp -UniquePermissions | Out-Null
            $currentWeb = Get-SPWeb $SiteURL
            Write-Verbose -Message 'Set the locale to en-UK'
            $culture=[System.Globalization.CultureInfo]::CreateSpecificCulture(“en-UK”) 
            $currentWeb.Locale=$culture 
            Write-Verbose -Message 'Enabling Tree View...'
            $currentWeb.TreeViewEnabled = $true
            $currentWeb.Update()
            Write-Debug -Message "Created site $SiteURL"
            $currentWeb.Dispose()
        }
    }
}