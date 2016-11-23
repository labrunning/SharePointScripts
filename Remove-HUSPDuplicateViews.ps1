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
    
function Remove-HUSPDuplicateViews {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list
    )

    $SPWeb = Get-SPWeb $url
    $listName = $SPWeb.GetList(($SPWeb.ServerRelativeURL.TrimEnd("/") + "/" + $list))
    
    $SPList = $SPWeb.Lists[$list]

    $SPViews = $SPList.Views

    ForEach ( $SPView in $SPViews | ? { $_.Url -match "\d.aspx" } ) {
        Write-Verbose -message "Removing view $SPView"
        $SPViewToDelete = $SPList.Views[$SPView]
        $SPList.Views.Delete($SPViewToDelete.ID)
    }
}