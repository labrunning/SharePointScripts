<#
    .SYNOPSIS
    Sets the Document Library settings to the defaults for the EDMRS system
    .DESCRIPTION
    This goes through all the document libraries in a site and sets the defaults for the EDRMS system which are;

        - OnQuickLaunch = $false
        - EnableVersioning = $true
        - EnableModeration = $false
        - EnableMinorVersions = $true
        - ForceCheckOut = $false
        - EnableFolderCreation = $false
        - ContentTypesEnabled = $true
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
        [Parameter(Mandatory=,Position=1)]
        [string]$url
    )

    $spWeb = Get-SPWeb $url
    
    foreach($docLib in $spWeb.Lists)
    {
        if( ($docLib.BaseType -eq "DocumentLibrary") -and ($docLib.Hidden -eq $false) )
        $CurrentDocumentLibrary = $docLib.Title
        write-verbose "Setting library defaults for $CurrentDocumentLibrary"
        $docLib.OnQuickLaunch = $false
        $docLib.EnableVersioning = $true
        $docLib.EnableModeration = $false
        $docLib.EnableMinorVersions = $true
        $docLib.ForceCheckOut = $false
        $docLib.EnableFolderCreation = $false
        $docLib.ContentTypesEnabled = $true
        $docLib.Update()
    }
    $spWeb.Dispose()
}