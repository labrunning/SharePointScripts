<#
    ################################################################
    .Synopsis
     Sends a message via the Pushover Service
    .DESCRIPTION
     Sends a message specified as a parameter via Luke's Pushover account
    .Parameter message
     The message you want sending
    .Parameter list
     A description of the url parameter
    .OUTPUTS
     A description of what the script outputs
    .EXAMPLE 
     An example of the command in use
    ################################################################
#>

function Send-PushoverMessage {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$message
    )
        
    $parameters = New-Object System.Collections.Specialized.NameValueCollection
    $parameters.Add("token", "ahsQYPP9AJstEbmHw9o66XDmY6xgCY")
    $parameters.Add("user", "ubxzmougpZ3ZybbaMX596yF6QKGLRv")
    $parameters.Add("message", $message)
    $client = New-Object System.Net.WebClient
    $client.UploadValues("https://api.pushover.net/1/messages.json", $parameters)

}