Param(
    [string]$url,
    [string]$list
    )

#Get destination site and list
$web = Get-SPWeb $url
$listName = $web.GetList(($web.ServerRelativeURL.TrimEnd("/") + "/" + $list))

$viewTitle = "University Committee by Academic Year" #Title property
#Add the column names from the ViewField property to a string collection
$viewFields = New-Object System.Collections.Specialized.StringCollection
$viewFields.Add("Document ID") > $null
$viewFields.Add("Committee Title") > $null
$viewFields.Add("Committee Date") > $null
$viewFields.Add("Committee Document Type") > $null
$viewFields.Add("University Committee Name") > $null
$viewFields.Add("Modified") > $null
$viewFields.Add("Modified By") > $null
$viewFields.Add("Version") > $null
#Query property
$viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE'/></OrderBy><GroupBy Collapse = 'FALSE'><FieldRef Name = 'Committee_x0020_Academic_x0020_Year'/></GroupBy>"
#RowLimit property
$viewRowLimit = 50
#Paged property
$viewPaged = $true
#DefaultView property
$viewDefaultView = $false

#Create the view in the destination list
$newview = $listName.Views.Add($viewTitle, $viewFields, $viewQuery, $viewRowLimit, $viewPaged, $viewDefaultView)
Write-Host ("View '" + $newview.Title + "' created in list '" + $listName.Title + "' on site " + $web.Url)
$web.Dispose()
