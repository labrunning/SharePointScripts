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

function Unlock-HUSPFile {    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$id
        )

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPItem = $SPList.GetItemById($id)
    $SPFile = $SPItem.File
    $SPLockType = $SPFile.LockType
    Write-Verbose -message "The file lock type is $SPLockType"

    If ($SPLockType -eq "Exclusive") {
        $SPUserToken = New-Object Microsoft.SharePoint.SPSite($SPWeb.site.id, $SPItem.File.LockedByUser.UserToken)
        $SPTokenWeb = $SPUserToken.OpenWeb($SPWeb.Id)
        $SPTokenList = $SPTokenWeb.Lists[$SPList]
        $SPTokenItem = $SPTokenList.GetItemById($id)
        $SPTokenItem.File.ReleaseLock($SPTokenItem.File.LockId)
        $SPTokenWeb.Dispose()
    }

    $SPLockType = $SPFile.LockType
    Write-Verbose -message "File lock type is now $SPLockType"
    $SPWeb.Dispose()

}