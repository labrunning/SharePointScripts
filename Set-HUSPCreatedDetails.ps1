<#
    .SYNOPSIS
    Sets the Created By and Created date to a given value
    .DESCRIPTION
    This script will set the created by and created date to a specified value rather than the defaults used by the system
    .PARAMETER url
    a valid SharePoint site url
    .PARAMETER listName
    a valid SharePoint list
    .PARAMETER fileName
    a valid filename in the list
    .EXAMPLE
    Set-HUSPCreatedDetails https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees 'University Health and Safety Committee' 'My Document.doc'
    .NOTES
    Some notes about the script
    .LINK
    a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>

function Set-HUSPCreatedDetails {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$listName,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$fileName
    )
    
    $web = get-SPWeb $url
    $list = $web.lists[$listName]
     
    $item = $list.Items | ? {$_.Name -eq $fileName}
     
    Write-Verbose ("item created by {0} on {1}" -f $item["Author"].tostring(), $item["Created"] )
    Write-Verbose ("item last modified by {0} on {1}" -f $item["Editor"].tostring(), ($item["Modified"] -f "dd-MM-yyyy"))
     
    $userLogin = "ad\cmsxsjg"
    $dateToStore = Get-Date "10/02/1984"
     
    $user = $web.EnsureUser($userLogin)
    $userString = "{0};#{1}" -f $user.ID, $user.UserLogin.Tostring()
     
    $item["Author"] = $userString
    $item["Created"] = $dateToStore
     
    $item["Editor"] = $userString
    $item["Modified"] = $dateToStore
     
    $item.UpdateOverwriteVersion()

    $web.Dispose()
} 