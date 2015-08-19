<#
    .SYNOPSIS
    Creates a set list view on a document Library
    .DESCRIPTION
    This script sets a specific view on a doument library. The view has;
    - Committee Title
    - Committee Document Type
    - Committee Date
    - Document ID
    - Version
    - Modified
    - Modified By
    Which is also grouped by Committee Academic Year. This script is a starting point to develop a set of standard views across all committee libraries.
    .PARAMETER url
    a valid SharePoint Site Url
    .PARAMETER list
    a valid SharePoint Document Library name
    .EXAMPLE
    Set-ListViews.ps1 -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -list 'University Health and Safety Committee'
    .NOTES
    Some notes about the script
    .LINK
    a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>

function New-HUSPListViews {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list
    )

    $web = Get-SPWeb $url
    $listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list))
    
    $viewTitle = "University Committee by Academic Year"
    $viewFields = New-Object System.Collections.Specialized.StringCollection
    $viewFields.Add("Committee Title") > $null
    $viewFields.Add("Committee Document Type") > $null
    $viewFields.Add("Committee Date") > $null
    $viewFields.Add("Document ID") > $null
    $viewFields.Add("Version") > $null
    $viewFields.Add("Modified") > $null
    $viewFields.Add("Modified By") > $null
    $viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE'/></OrderBy><GroupBy Collapse = 'FALSE'><FieldRef Name = 'Committee_x0020_Academic_x0020_Year'/></GroupBy>"
    $viewRowLimit = 50
    $viewPaged = $true
    $viewDefaultView = $false
    
    Write-Verbose ("Creating View '" + $newview.Title + "' created in list '" + $listName.Title + "' on site " + $web.Url)
    $newview = $listName.Views.Add($viewTitle, $viewFields, $viewQuery, $viewRowLimit, $viewPaged, $viewDefaultView)
    
    $web.Dispose()
}
