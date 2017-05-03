# Export Sharepoint User Profiles to CSV file
# John Lynch 2013
# MIT License

function Export-HUSPUserProfileService {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$path
    )   

    $SPSiteUrl = $url
    $SPOutputFile = $path

    $SPServiceContext = Get-SPServiceContext -Site $SPSiteUrl
    $SPProfileManager = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($SPServiceContext)
    $SPProfiles = $SPProfileManager.GetEnumerator()

    $SPFields = @(
        "SID",
        "ADGuid",
        "AccountName",
        "FirstName",
        "LastName",
        "PreferredName",
        "WorkPhone",
        "Office",
        "Department",
        "Title",
        "Manager",
        "AboutMe",
        "UserName",
        "SPS-Skills",
        "SPS-School",
        "SPS-Dotted-line",
        "SPS-Peers",
        "SPS-Responsibility",
        "SPS-PastProjects",
        "SPS-Interests",
        "SPS-SipAddress",
        "SPS-HireDate",
        "SPS-Location",
        "SPS-TimeZone",
        "SPS-StatusNotes",
        "Assistant",
        "WorkEmail",
        "SPS-ClaimID",
        "SPS-ClaimProviderID",
        "SPS-ClaimProviderType",
        "CellPhone",
        "Fax",
        "HomePhone",
        "PictureURL"
    )

    $SPCollection = @()

    foreach ($SPProfile in $SPProfiles) {
        $SPUser = "" | select $SPFields
        foreach ($SPField in $SPFields) {
            if($SPProfile[$SPField].Property.IsMultivalued) {
                $SPUser.$SPField = $SPProfile[$SPField] -join "|"
            } else {
                $SPUser.$SPField = $SPProfile[$SPField].Value
            }
        }
        $SPCollection += $SPUser
    }

    $SPCollection | Export-Csv $SPOutputFile -NoTypeInformation

}