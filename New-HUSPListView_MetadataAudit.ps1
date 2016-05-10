<#
    .SYNOPSIS
    Creates a set list view on a document Library
    .DESCRIPTION
    This script sets a specific view on a document library. 
    .PARAMETER url
    a valid SharePoint Site Url
    .PARAMETER list
    a valid SharePoint Document Library name
    .PARAMETER column
    a valid SharePoint Document Library column
    .EXAMPLE
    New-HUSPListView_MetadataAudit.ps1 -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -list 'University Health and Safety Committee' -column 'University Committee Name'
    .NOTES
    Some notes about the script
    .LINK
    a cross-reference to another help topic; you can have more than one of these. If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>

function New-HUSPListView_MetadataAudit {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$column
    )

    $web = Get-SPWeb $url
    $listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list))
    
    $viewTitle = "Metadata Audit"
    $viewFields = New-Object System.Collections.Specialized.StringCollection
    $viewFields.Add("DocIcon") > $null
    $viewFields.Add("LinkFilename") > $null
    $viewFields.Add($column) > $null
    $viewFields.Add("Committee Academic Year") > $null
    $viewFields.Add("Committee Date") > $null
    $viewFields.Add("Committee Document Type") > $null
    $viewFields.Add("ID") > $null
    $viewQuery = "<OrderBy><FieldRef Name='ID' Ascending='TRUE'/></OrderBy>"
    $viewRowLimit = 100
    $viewPaged = $true
    $viewDefaultView = $false
    
    Write-Verbose -message "Creating View $viewTitle for $list"
    $newview = $listName.Views.Add($viewTitle, $viewFields, $viewQuery, $viewRowLimit, $viewPaged, $viewDefaultView)
    
    $web.Dispose()
}
