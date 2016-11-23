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
    
function Set-HUSPMigrationFlag {
    
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url
    )
    
    $SPParentWeb = Get-SPWeb $url

    ForEach ( $SPWeb in $SPParentWeb.Webs ) {
        $SPSubWeb = Get-SPWeb $SPWeb.Url
        ForEach ( $SPList in $SPSubWeb.Lists | Where-Object { $_.Hidden -eq $false -and $_.Title -NotLike "*Drop*" -and $_.Title -NotLike "*Audit Reports" } ) {
            $SPList.Title
            Write-Host ++++++++++++++++++++++++++++++++++++
            $SPItems = $SPList.Items
            ForEach ($SPItem in $SPItems | Where-Object { $_.Properties['vti_modifiedby'] -ne 'SHAREPOINT\system' } ) {
            <#ForEach ($SPItem in $SPItems) {#>
                <#Write-Host $SPItem.Id "|" $SPItem.Name "|" $SPItem.Properties['vti_modifiedby'] "|" $SPItem.Properties['Committee Paper Number']#>
                $SPItem.Fields | foreach {
                    $SPFieldValues = @{
                        "Display Name" = $_.Title
                        "Internal Name" = $_.InternalName
                        "Value" = $SPItem[$_.InternalName]
                    }
                    New-Object PSObject -Property $SPFieldValues | Select @("Display Name","Internal Name","Value")
                }
            }
        }
        $SPSubWeb.Dispose()
    }
    $SPParentWeb.Dispose()
}