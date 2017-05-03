<#
    ################################################################
    .Synopsis
     Unlocks a file on SharePoint which is locked exclusively
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
        [string]$Id
    )

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]

    # FIXME this is really slow; change to using a CAML query to speed it up?
    # Nope, didn't really work
    $SPItem = $SPList.GetItemById($id)
    $SPFile = $SPItem.File
    # FIXME we are only interested in the lock info, can we filter the properties returned to speed it up?
    $SPFile
    $SPLockType = $SPFile.LockType
    Write-Output "File lock type is: $SPLockType"

    If ($SPLockType -eq "Exclusive") {
        Write-Output "Attempting Unlock..."
        $SPUserToken = New-Object Microsoft.SharePoint.SPSite($SPWeb.site.id, $SPItem.File.LockedByUser.UserToken)
        $SPTokenWeb = $SPUserToken.OpenWeb($SPWeb.Id)
        $SPTokenList = $SPTokenWeb.Lists[$SPList]
        $SPTokenItem = $SPTokenList.GetItemById($id)
        $SPTokenItem.File.ReleaseLock($SPTokenItem.File.LockId)
        $SPTokenWeb.Dispose()
    }

    $SPWeb.Dispose()

}