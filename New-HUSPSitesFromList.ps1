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
    .PARAMETER st
    a valid SharePoint Site Template code (default is BDR#0 which is a Document Centre ); use Get-SPWebTemplate to see a full list
    .EXAMPLE
    An example of how the script can be used\script
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
        [string]$st = "BDR#0" # Document Centre
    )
    
    Write-Verbose "Site template is $st"

    Write-Verbose -Message "Importing list of sites from $csv"
    $SitesList = Import-Csv -Path "$csv"
    
    Write-Verbose "You are about to create the following sites;"
    $SitesList
    $ConfirmCreateSites = Read-Host "Are you Sure You Want To Proceed: (press 'y' to proceed)"

    If ($ConfirmCreateSites -eq 'y') {
        ForEach ($site in $SitesList) {
            $SiteCollection = "$url"
            $SiteURL = $SiteCollection.TrimEnd("/") + "/" + $site.URL
            Write-Verbose "Creating $SiteURL..."
            New-SPWeb -Url $SiteURL -Name $site.Name -Description $site.Description -Template $st -UniquePermissions | Out-Null
            $SPWeb = Get-SPWeb $SiteURL
            Write-Verbose -Message 'Set the locale to en-GB'
            # this is now GB
            $culture=[System.Globalization.CultureInfo]::CreateSpecificCulture('en-GB') 
            $SPWeb.Locale=$culture 
            Write-Verbose -Message 'Enabling Tree View...'
            $SPWeb.TreeViewEnabled = $true
            Write-Verbose -Message 'Disabling Quick Launch...'
            $SPWeb.QuickLaunchEnabled = $false
            $SPWeb.Update()

            # get rid of the documents and tasks apps
            foreach ($DefaultLibrary in "Documents","Tasks") {
                $LibraryToDelete = $SPWeb.Lists[$DefaultLibrary]
                $LibraryToDelete.Delete()
            }

            # turn on/off the feature we need
            ## Content Organizer
            Enable-SPFeature -Identity "DocumentRouting" -URL $SPWeb.url | Out-Null
            $SPDropOffLib = $SPWeb.Lists["Drop Off Library"]
            $SPDropOffLib.Title = "@Drop Off Library"
            $SPDropOffLib.Update()

            # Create a audit log document library for the site
            $listTemplate = [Microsoft.SharePoint.SPListTemplateType]::DocumentLibrary
            $SPWeb.Lists.Add("@Audit Reports","A place to save audit log reports.",$listTemplate)

            # Disabling Unwanted Features
            Disable-SPFeature -Identity "FollowingContent" -URL $SPWeb.url -Force -Confirm:$false | Out-Null
            Disable-SPFeature -Identity "MBrowserRedirect" -URL $SPWeb.url -Force -COnfirm:$false | Out-Null

            # Update everything before we leave
            $SPWeb.Update()
            Write-Verbose -Message "Created site $SPWeb"
            Write-Host "Site GUID is " $SPWeb.ID
            $SPWeb.Dispose()
        }
    }
}