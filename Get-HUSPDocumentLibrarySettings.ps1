    <#
    ################################################################
    .Synopsis
     A brief outline of what the script does
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
    
function Get-HUSPDocumentLibrarySettings {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$false,Position=2)]
        [string]$out="D:\SPOutput"
    )


    $SPSite = Get-SPSite $url

    $SPWebs = $SPSite.AllWebs

    ForEach ($SPWeb in $SPWebs) {
        $SPLists = $SPWeb.Lists | Where-Object { $_.BaseTemplate -eq "DocumentLibrary" -and $_.Hidden -eq $false -and $_.IsSiteAssetsLibrary -eq $false}
        ForEach ($SPList in $SPLists) {
            $SPListValues = @{
                "Site" = $SPList.ParentWeb
                "Title" =  $SPList.Title
                "Url" = $SPList.Url
                "EnableVersioning" = $SPList.EnableVersioning
                "ShowUser" = $SPList.ShowUser
                "MajorVersionLimit" = $SPList.MajorVersionLimit
                "MajorWithMinorVersionsLimit" = $SPList.MajorWithMinorVersionsLimit
                "IsCatalog" = $SPList.IsCatalog
                "Author" = $SPList.Author
                "ItemCount" = $SPList.ItemCount
            }

            New-Object PSOBject -Property $SPListValues | Select @("Site","Title","Url","Author","EnableVersioning","MajorVersionLimit","MajorWithMinorVersionsLimit","ItemCount")

            <#If ($SPListVersionsEnabled -eq $true) {
                    Write-Host "$SPList in $SPWeb has versioning set to $SPListVersionsEnabled" -foregroundcolor green
                } else {
                    Write-Host "$SPList in $SPWeb has versioning set to $SPListVersionsEnabled" -foregroundcolor red
            }#>
        }
        $SPWeb.Dispose()       
    }
    $SPWebs.Dispose()
    $SPSite.Dispose()
}