<#
    ################################################################
    .Synopsis
     Sets the email to send site requests to across a web application 
    .DESCRIPTION
     Same as the synopsis
    .Parameter webapp
     A valid SharePoint web application
    .Parameter email
     A valid email to use for all site access requests
    .OUTPUTS
     Sets all the emails in the site access request settings
    .EXAMPLE 
     Set-HUSPSiteAccessRequestEmails -webapp https://unishare.hud.ac.uk -email l.brunning@hud.ac.uk£
    ################################################################
#>
    

function Set-HUSPSiteAccessRequestEmails {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$webapp,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$email
        )
    

    $WebapplicationValue = Read-Host "Enter web application URL"
    Write-Host $WebapplicationValue

    $SPWebApp = Get-SPWebApplication $webapp
    $newEmail = $email

    foreach($SPSite in $SPWebApp.Sites)
    {
        Write-Host "Site URL is" $SPSite
        foreach($SPWeb in $SPSite.AllWebs)
        {
            $SPurl = $SPWeb.url
            Write-host "Site URl: " $SPurl
            if (!$SPWeb.HasUniquePerm) {
                Write-Host "Access Request Settings is inherted from parent."
            } else {
                if($SPWeb.RequestAccessEnabled) {
                    Write-Host "Access Request Settings is enabled."
                    Write-Host "Email needs to be updated."
                    $SPWeb.RequestAccessEmail = $newEmail
                    $SPWeb.Update()
                    Write-Host "Email changed successfully!"
                }
            } else {
                Write-Host "Access Request Settings not enabled."
            }
        }
    }
}