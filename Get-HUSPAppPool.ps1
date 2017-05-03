<#
    .Synopsis
     Get IIS application pool status
    .DESCRIPTION
     The function would provide IIS application pool status
    .EXAMPLE
     Get-AppPool -Server server1,server2 -Pool powershell
    .FUNCTIONALITY
     It uses Microsoft.Web.Administration assembly to get the status
#>

function Get-HUSPAppPool {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string[]]$servers
    )

    [Reflection.Assembly]::LoadWithPartialName('Microsoft.Web.Administration') | Out-Null

    # This article suggests the best way to create and add to arrays is the ArrayList method
    # https://learn-powershell.net/2014/09/21/quick-hits-adding-items-to-an-array-and-a-look-at-performance/
    $serverList = @{}
    
    foreach ($server in $servers) {
        $serverAppPools = @{}
        $serverManager = [Microsoft.Web.Administration.ServerManager]::OpenRemote($server)

        $serverManager.ApplicationPools | % {
            $serverAppPools += @{
                $_.Name = $_.State
            }
        }
        $serverList.Add($server,$serverAppPools)
    }

    $serverList
}