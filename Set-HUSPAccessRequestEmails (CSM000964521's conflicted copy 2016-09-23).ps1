<#
    ################################################################
    .Synopsis
     Sets the email to send site requests to across a web application 
    .DESCRIPTION
     Sets the access request email to the one supplied as a parameter. To turn off access requests use -email " "
    .Parameter webapp
     A valid SharePoint web application
    .Parameter email
     A valid email to use for all site access requests
    .OUTPUTS
     Sets all the emails in the site access request settings
    .EXAMPLE 
     Set-HUSPSiteAccessRequestEmails -webapp https://unishare.hud.ac.uk -email " "
     This will turn off access requests
    ################################################################
#>

function Set-HUSPAccessRequestEmails {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$webapp,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$email
    )
    
    $SPWebApp = Get-SPWebApplication $webapp
    $newEmail = $email

    foreach($SPSite in $SPWebApp.Sites) {
        Write-Host "Site URL is" $SPSite
        foreach($SPWeb in $SPSite.AllWebs) {
            $SPurl = $SPWeb.url
            Write-host "Site Url: " $SPurl
            if (!$SPWeb.HasUniquePerm) {
                Write-Host "Access Request Settings is inherted from parent."
                } else { # does not inherit permissions from parent
                    if($SPWeb.RequestAccessEnabled) {
                        Write-Host "Access Request Setting is enabled"
                        Write-Host "Email updated to $email"
                        $SPWeb.RequestAccessEmail = $newEmail
                        $SPWeb.Update()
                        Write-Host "Email changed successfully!"
                    } else {
                    Write-Host "Access Request Settings not enabled."
                }
            } 
        } # end webs loop
    } # end sites loop
}