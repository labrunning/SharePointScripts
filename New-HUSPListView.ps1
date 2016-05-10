<#
    .SYNOPSIS
    Creates a set list view on a document Library from an XML file
    .DESCRIPTION
    This script sets a view accorind to the data in an XML file
    .PARAMETER url
    a valid SharePoint Site Url
    .PARAMETER list
    a valid SharePoint Document Library name
    .PARAMETER xml
    a valid path to an XML file with the view data
    .EXAMPLE
    Set-ListViews.ps1 -url https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -list 'University Health and Safety Committee' xml '.\CommitteesAcademicYearView.xml'
#>

function New-HUSPListView {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$xmlpath
    )
    
    [xml]$viewData = Get-Content -Path $xmlpath

    $SPWeb = Get-SPWeb $url
    $listName = $SPWeb.GetList(($SPWeb.ServerRelativeURL.TrimEnd("/") + "/" + $list))

    $viewTitle = $viewData.View.Name

    $viewFields = New-Object System.Collections.Specialized.StringCollection

    $myFields = Select-Xml "//ViewFields/*" $viewData
    $myFields | ForEach-Object {
        $viewFields.Add($_.Node.Name) > $null
    }

    $viewQuery = Select-XML "//Query" $viewData

    $viewRowLimit = $viewData.View.RowLimit.InnerText 
    $viewPaged = $viewData.View.RowLimit.Paged
    # the view setting is funny about it's booleans!
    # a regular boolean won't work, so set to $true when TRUE
    If ($viewPaged -eq "TRUE") {
        $viewPaged = $true
    } else {
        $viewPaged = $false
    }
    $viewDefaultView = $viewData.View.DefaultView
    If ($viewDefaultView -eq "TRUE") {
        $viewDefaultView = $true
    } else {
        $viewDefaultView = $false
    }
    
    $newview = $listName.Views.Add($viewTitle, $viewFields, $viewQuery, $viewRowLimit, $viewPaged, $viewDefaultView)
    Write-Host ("Created View '$viewTitle' for '$list'")
    
    $aggregations = Select-XML "//Aggregations" $viewData
    
    $SPList = $SPWeb.Lists[$list]
    $SPView = $SPList.Views[$viewTitle]

    $SPView.Aggregations = $aggregations
    $SPView.AggregationsStatus = $true
    $SPView.Update()
    $SPList.Update()

    $SPWeb.Dispose()
}