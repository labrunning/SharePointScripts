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

function Invoke-HUSPFileLockRelease {    

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$itemid
    )

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPItem = $SPList.GetItemById($itemid)

    $SPFile = $SPItem.File

    $SPLockType = Select-String -pattern "LockType" -InputObject $SPFile -List

    Write-Verbose -Message $SPLockType


    #try {
    #    $SPSite = New-Object Microsoft.SharePoint.SPSite($SPWeb.Site.Id, $SPItem.File.LockedByUser.UserToken)
    #    $SPWeb = $SPSite.OpenWeb($SPWeb.Id)
    #    $SPList = $SPWeb.Lists[$SPListist]
    #    $SPItem = $SPList.GetItemById($SPItem)
    #    $SPItem.File.ReleaseLock($SPItem.File.LockId)
    #} catch [System.SystemException] {
    #    write-host "The script has stopped because there has been an error.  "$_.Message
    #   
    #}

    $SPWeb.Dispose()
    $SPSite.Dispose()
}