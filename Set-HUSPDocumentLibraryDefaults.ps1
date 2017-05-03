<#
    .SYNOPSIS
    Sets the Document Library settings to the defaults for the EDMRS system
    .DESCRIPTION
    This goes through all the document libraries in a site and sets the defaults for the EDRMS system
    .PARAMETER param
    a description of a parameter
    .EXAMPLE
    An example of how the script can be used
    .NOTES
    Some notes about the script
    .LINK
    a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>

function Set-HUSPDocumentLibraryDefaults {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$list
    )

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    Write-Verbose -message "Setting library defaults for $SPList"
    $SPList.EnableFolderCreation = $false
    # changed DisableGridEditing to $false so that people can edit bulk uploads
    $SPList.DisableGridEditing = $false
    $SPList.Update()
    $SPWeb.Update()
    
    $SPWeb.Dispose()
}