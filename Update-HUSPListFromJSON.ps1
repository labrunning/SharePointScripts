<#
    ################################################################
    .Synopsis
     Updates a SharePoint list from a JSON file
    .DESCRIPTION
     Given a JSON file this will update a list with corresponding columns
    .Parameter url
     A valid SharePoint web url
    .Parameter list
     A valid SharePoint list
    .Parameter json
     A valid JSON file
    .Parameter title
     The column to be added to the 'Title' column in the list
    .OUTPUTS
     An updated SharePoint list
    .EXAMPLE 
     An example of the command in use
        Update-HUSPUpdateListFromJSON -url https://unishare.hud.ac.uk/show -list "SANResults" -json .\SPInput\san_results.json -title "VMName"
    ################################################################
#>

function Update-HUSPListFromJSON {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$json,
        [Parameter(Mandatory=$True,Position=4)]
        [string]$title
    )

    $FileExists = (Test-Path $json -PathType Leaf) 

    If ($FileExists -eq $true) { 
            Write-Host "Loading $json for processing..." 
            $jsonFile = ConvertFrom-Json -InputObject (Get-Content $json -Raw)
        } Else { 
            Write-Output "$json not found - stopping import!" 
            Break
    }

    $SPWeb = Get-SPWeb $url
    $SPExistingList = $SPWeb.Lists[$list]

    # Delete the existing list
    try {
        Write-Host "Deleting list: $list"
        $SPExistingList.Delete()
    } catch [Exception]{
        Write-Error $_.Exception | format-list -force
    }
    
    # Recreate the list
    $SPListTemplate = [Microsoft.SharePoint.SPListTemplateType]::GenericList
    $SPWeb.Lists.Add($list,"List added by script",$SPListTemplate)
    $SPCurrentList = $SPWeb.Lists[$list]

    $JSONData = ConvertFrom-Json -InputObject (Get-Content $json -Raw)
    $JSONDataCount = $JSONData.Count

    $JSONfields = @()
    
    # Iterate over the JSON data    
    $i = 0
    $JSONData | % {
        try {
            $id = $i + 1
            $SPNewItem = $SPCurrentList.AddItem()
            $_ | Get-Member -Type NoteProperty | % {
                $JSONColumnDefinition = $_.Definition -split " "
                $colType = $JSONColumnDefinition[0]
                $JSONItemName = $_.Name
                $JSONItemData = $JSONData[$i].$JSONItemName
                # Write-Host "`rAdding item number $id of $JSONDataCount - $JSONItemName is $JSONItemData" -nonewline
                Write-Host "Adding item number $id of $JSONDataCount - $JSONItemName is $JSONItemData"
                if ($JSONItemName -eq $title) {
                        # write the title field into the title column
                        $SPNewItem["Title"] = $JSONItemData
                    } else {
                        $colExists = $SPCurrentList.Fields.ContainsField($JSONItemName)
                        # check to see if the JSON field item has a column
                        if ( $SPCurrentList.Fields.ContainsField($JSONItemName) -eq $false ) {
                            # add this field to the array we will use to create the all columns view
                            switch ($colType) {
                                "System.String" {
                                    Write-Host "Create a Single line of text column called $JSONItemName"
                                    $SPFieldType = [Microsoft.SharePoint.SPFieldType]::Text
                                    # the last parameter is for 'required?'
                                    $SPCurrentList.Fields.Add($JSONItemName,$SPFieldType,$false)
                                    $SPCurrentList.Update()
                                }
                                "System.Int32" {
                                    Write-Host "Create a number column called $JSONItemName"
                                    $SPFieldType = [Microsoft.SharePoint.SPFieldType]::Number
                                    $SPCurrentList.Fields.Add($JSONItemName,$SPFieldType,$false)
                                    $SPCurrentList.Update()
                                }
                                "System.Boolean" {
                                    Write-Host "Create a yes/no column called $JSONItemName"
                                    $SPFieldType = [Microsoft.SharePoint.SPFieldType]::Boolean
                                    $SPCurrentList.Fields.Add($JSONItemName,$SPFieldType,$false)
                                    $SPCurrentList.Update()
                                }
                                Default {
                                    Write-Host "Create a Single line of text column called $JSONItemName"
                                    $SPFieldType = [Microsoft.SharePoint.SPFieldType]::Text
                                    $SPCurrentList.Fields.Add($JSONItemName,$SPFieldType,$false)
                                    $SPCurrentList.Update()
                                }
                            }
                            $JSONfields += $JSONItemName
                        } else {
                            Write-Host "**Column $JSONItemName already exists**"
                        }
                        # if there is a value in the JSON file, write it
                        if ($JSONItemData -eq "-" -or $JSONItemData -eq $null) {
                            # Don't write owt it's blank
                            Write-Verbose "No value to write to column"
                        } else {
                            Write-Verbose "Writing value $JSONItemData to column $JSONItemName"
                            $SPNewItem[$JSONItemName] = $JSONItemData
                    }
                }
            }
            $SPNewItem.Update()
        } catch [Exception]{
            Write-Error "Error writing $JSONItemData to $JSONItemName"
            Write-Error $_.Exception | format-list -force
        }
        $i++
    }
        
    # Create a view with all the fields in
    $SPViewXMLQuery = "<OrderBy><FieldRef Name='Title' Ascending='TRUE'/></OrderBy>"
    # for the fields, loop through them and add the user generated ones
    $SPViewXMLFields = New-Object System.Collections.Specialized.StringCollection
    $SPViewXMLFields.Add("Title")
    $JSONfields | % {
        $SPViewXMLFields.Add("$_") > $null
    }
    $SPViewXMLRowLimit = "100"
    $SPViewXMLAggregations = "<Aggregations><FieldRef Name='Title' Type='COUNT'/></Aggregations>"
    $SPViewPaged = $true
    $SPViewDefaultView = $false
    
    $SPViewTitle = "All Fields"

    $SPViewFields = New-Object System.Collections.Specialized.StringCollection

    $SPView = $SPCurrentList.Views[$SPViewTitle]

    if ( $SPView -eq $null ) {
            $newview = $SPCurrentList.Views.Add($SPViewTitle, $SPViewXMLFields, $SPViewXMLQuery, $SPViewXMLRowLimit, $SPViewPaged, $SPViewDefaultView)
            $SPView = $SPCurrentList.Views[$SPViewTitle]
            $SPView.Aggregations = $SPViewXMLAggregations
            $SPView.AggregationsStatus = $true
            $SPView.Update()
            $SPCurrentList.Update()
            Write-Output "Created view $SPViewTitle for $list"
        } else {
            Write-Output "View $SPViewTitle already exists; will not be created"
    }


    $SPWeb.Dispose()

}