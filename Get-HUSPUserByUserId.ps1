function Get-HUSPUserByUserId { 
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$site,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$UserID
    )

    $SPSite=Get-SPSite -Identity $site 
    $SPWeb=$SPSite.OpenWeb()         
    $SPUser=$SPWeb.Users.GetByID($UserID) 
    $SPUserName=$SPUser.Name 
 
    Write-Host $SPUserName

    $SPWeb.Dispose()      
    $SPSite.Dispose() 

}