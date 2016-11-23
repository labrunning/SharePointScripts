<#
    ################################################################
    .Synopsis
     Removes the setup account from the groups that GB creates
    .DESCRIPTION
     Removes the sp2013setup account from the UF groups that GB creates
    .Parameter url
     A description of the url parameter
    .OUTPUTS
     A description of what the script outputs
    .EXAMPLE 
     An example of the command in use
    ################################################################
#>

function Remove-HUSPSetUpAccounts {

    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url
    )
        
    $SPWeb = Get-SPWeb $url
    $SPGroups = $SPWeb.Groups

    ForEach ($SPGroup in $SPGroups | Where { $_.Name -like "UF*" } ) {
        Write-Verbose -message "$SPGroup is a Unifunctions Group"
        ForEach ($SPUser in $SPGroup.Users | Where { $_.DisplayName -eq "sp2013setup" } ) {
            Write-Verbose -message "$SPUser is present in $SPGroup"
            $SPUser = $SPWeb.AllUsers.Item($SPUser.UserLogin)
            Write-Verbose -message "$SPUser will be removed"
            $SPGroup.RemoveUser($SPUser)
            Write-Verbose -message "$SPUser removed"
        }
    }
}    