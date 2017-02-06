function Get-HUSPContentTypesInUse {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$ct
        )

    $SPSite = Get-SPSite($url)
    foreach ($Web in $SPSite.AllWebs) {
        
        $SPWeb = Get-SPWeb $Web.Url
        $SPCType = $SPWeb.ContentTypes[$ct]
        
        try {
            $SPUsages = [Microsoft.Sharepoint.SPContentTypeUsage]::GetUsages($SPCType)
            foreach ($SPUsage in $SPUsages) {
                Write-Output $SPUsage.Url
            }
        } catch {}
        
        $SPWeb.Dispose()
        
    }
}