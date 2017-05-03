<# 
    .SYNOPSIS
     Applies metadata from the WISDOM archived metadata XML to a field in the list
    .DESCRIPTION
     For a given list this script will apply a metadata value to every item in this list based on the list name which matches the supplied CAML query. This can be used to apply metadata not brought over in the migration; any managed metadata fields that are being written to MUST have a corresponding entry in the term set; unmatched values will not create a term set. You can test CAML queries with the Test-HUSPCamlQuery function.
    .PARAMETER url
      A valid SharePoint list url
    .PARAMETER list
      A valid SharePoint list name
    .PARAMETER xpath
      A valid XML path for the archived metadata field value
    .PARAMETER field
      A valid SharePoint field you want to write to
    .PARAMETER caml
      A valid path to an XML file with a CAML query for the items you want to use
    .PARAMETER write
      A flag to state whether you want to actually write the values
    .PARAMETER group
      A valid term store group for any managed metadata (defaults to "UF Fileplan")
    .PARAMETER set
      A valid term set for the terms you want to search in  
    .OUTPUTS
      All the documents in the list will have the metadata term applied
    .EXAMPLE 
      Edit-HUSPMetadataFromXML -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee" -xpath "subjects" -field "School of Education and Professional Development Subject" -caml ".\scripts\xml\caml_nullsubjects.xml" -group "UF Fileplan" -set "Subjects"
#>

function Get-HUSPTaxonomyValue($value) {
    $SPTaxonomyValue = $value.Trim()
    Write-Verbose -Message "Looking for $SPTaxonomyValue"
    $SPTaxonomySession = Get-SPTaxonomySession -Site $SPWeb.Site
    $SPTermStore = $SPTaxonomySession.TermStores[0] 
    $SPTermStoreGroup = $SPTermStore.Groups[$group] 
    $SPTermSet = $SPTermStoreGroup.TermSets[$set] 
    # This is currently only going to work for the subjects due to the 'WHERE' function at the end
    try {    
        $SPTerm = $SPTermSet.GetTerms($SPTaxonomyValue,$true) | Where-Object { $_.Parent.Name -eq $SPWeb.Title }
        $SPTermValueGuid = $SPTerm.Id
        Write-Verbose -Message "Term ID is $SPTermValueGuid"
        $SPTaxonomyField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$SPList.Fields[$field]
        [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$SPTaxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($SPTaxonomyField)    
        $SPTaxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($SPTaxonomyValue) + "|" + $SPTermValueGuid)
        $setFieldValue = $SPTaxonomyFieldValue.ValidatedString
        $setFieldValue
        if ($PSCmdlet.ShouldProcess($value)) {
            $ModifyRecord = {
                $SPItem[$field] = $setFieldValue
                $SPItem.SystemUpdate($false)
            }
            $RecordsManagement::BypassLocks($SPItem, $ModifyRecord)
        }
    } catch [Exception]{
        Write-Error $_.Exception | format-list -force
    }
}

function Get-HUSPDateTimeValue($value,$pathstr) {
    # date patterns
    $myYearRegex = "Year-([0-9]{4})-([0-9]{4})"
    # $myMonthRegex = "[0-9]{1,2}?[\. _-]?(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[uary|ch|il|e|y|ust|t|tember|ober|ember]?"
    $myMonthRegex = "(\bJan(?=uary|[\' \._-]|[0-9]{2})|\bFeb(?=uary|[\' \._-]|[0-9]{2})|\bMar(?=ch|[\' \._-]|[0-9]{2})|\bApr(?=il|[\' \._-]|[0-9]{2})|\bMay(?![a-z])|\bJun(?=e|[\' \._-]|[0-9]{2})|\bJul(?=y|[\' \._-]|[0-9]{2})|\bAug(?=ust|[\' \._-]|[0-9]{2})|\bSep(?=t|[\' \._-]|[0-9]{2})|\bSep(?=tember|[\' \._-]|[0-9]{2})|\bOct(?=ober|[\' \._-]|[0-9]{2})|\bNov(?=ember|[ \._-]|[0-9]{2})|\bDec(?=ember|[\' \._-]|[0-9]{2}))"    
    $myFullDateRegex = "([0-9]{1,2})(?:st|nd|rd|th)?[\. _-]?(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[uary|ch|il|e|y|ust|t|tember|ober|ember]?[\. _-]?([0-9]{2,4})"
    $myDateRegex = "([0-9]{1,2})(?:st|nd|rd|th)?[\. _-]?(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|Sept)[a-z]{0,6}"

    ## If we can find a valid date in the TITLE we don't need to look for date componenets
    ## The TITLE contains the file title as well so we don't need to handle this any differently
    If ($value -imatch $myFullDateRegex) { 
        $myDate = $matches[1]
        $myMonth = $matches[2]
        $myYear = $matches[3]
        # We need to do some year sanity checks here;
        If ( $myYear.Length -lt 4 ) {
             # make it a nice date
             If ( $myYear -lt 70 ) {
                 [int]$myYear = [int]$myYear + 2000
             } Else {
                 [int]$myYear = [int]$myYear + 1900
             }
        } Else {
            # leave it as is
            $myYear = $matches[3]
        }
        [int]$myFirstYear = $myYear
        [int]$mySecondYear = $myYear
        Write-Verbose -Message "Full date matched - Date: $myDate Month: $myMonth Year: $myYear "
    ## If we can't find a valid date in the archivestr we need to look for date componenets
    } Else {
        # Look for a **YEAR**
        If ($pathstr -imatch $myYearRegex) {
            # we found a year
            ## Seperate into first and second years
            $myFirstYear = $matches[1]
            $mySecondYear = $matches[2]
            Write-Verbose -Message "The first year is $myFirstYear the second year is $mySecondYear"
        } else {
            Write-Verbose -Message "Could not find a year in $pathstr"
        } # end looking for a **YEAR** (if there wasn't a year, I'm not sure we should look further)

        # Look for a **MONTH**
        If ($pathstr -imatch $myMonthRegex) {
            $myMonth = $matches[1]
            Write-Verbose -Message "The month is $myMonth"
        } else {
        # Let's just use september (string or integer?)
            $myMonth = "Sep"
            Write-Verbose -Message "No month matched; using Sep"
        } # end looking for a **MONTH**

        # Look for a **DATE**
        If ($pathstr -imatch $myDateRegex) {
            $myDate = $matches[1]
            Write-Verbose -Message "The date is $myDate"
        } else {
        # Let's just use the first of the month (string or integer?)
            [int]$myDate = 1
            Write-Verbose -Message "No date matched; using 1"
        } # end looking for a **DATE**

    } # end looking for **DATE COMPONENTS**

    # Let's try to create a date
    <#
        DO THEY KNOW THE RHYME?!
        (They don't in SEPD...)
        Thirty days has September,
        April, June, and November.
        All the rest have thirty-one,
        Except for February alone,
        Which has but twenty-eight days clear,
        And twenty-nine in each leap year.
    #>
    switch ($myMonth) {
        "Jan" { $monthLimit = 31; $myYear = $mySecondYear; $myMonthInt = 1}
        "Feb" { 
            # is it a leap year?
            if ( $year % 4 -eq 0 -and $year % 100 -ne 0 -or $year % 400 -eq 0 ) {
                # Leap Year
                Write-Verbose -Message "Leap Year"
                $monthLimit = 29
            } else {
                $monthLimit = 28
            }
            $myYear = $mySecondYear
            $myMonthInt = 2
        }
        "Mar" { $monthLimit = 31; $myYear = $mySecondYear; $myMonthInt = 3 }
        "Apr" { $monthLimit = 30; $myYear = $mySecondYear; $myMonthInt = 4 }
        "May" { $monthLimit = 31; $myYear = $mySecondYear; $myMonthInt = 5 }
        "Jun" { $monthLimit = 30; $myYear = $mySecondYear; $myMonthInt = 6 }
        "Jul" { $monthLimit = 31; $myYear = $mySecondYear; $myMonthInt = 7 }
        "Aug" { $monthLimit = 31; $myYear = $mySecondYear; $myMonthInt = 8 }
        "Sep" { $monthLimit = 30; $myYear = $myFirstYear; $myMonthInt = 9 }
        "Oct" { $monthLimit = 31; $myYear = $myFirstYear; $myMonthInt = 10 }
        "Nov" { $monthLimit = 30; $myYear = $myFirstYear; $myMonthInt = 11 }
        "Dec" { $monthLimit = 31; $myYear = $myFirstYear; $myMonthInt = 12 }
        Default { $monthLimit = $null; Write-Verbose "Somehow we did not get a month limit" }
    } # end switch month
    [int]$myDateInt = $myDate
    if ( $myDateInt -gt $monthLimit ) {
        Write-Verbose -Message "They did not know the rhyme; month limit is $monthLimit"
        [int]$myDate = [int]$monthLimit
    } else { 
        # Write-Verbose -Message "They knew the rhyme!"
    } # end check to see if they know the limit of days in a month and decide which year to use
    try {
        $setFieldValue = Get-Date -Year $myYear -Month $myMonthInt -day $myDate
        $myLongDate = $setFieldValue.ToLongDateString()
        Write-Host "We have a validated date of $myLongDate" -ForegroundColor "Green"
        if ($PSCmdlet.ShouldProcess($value)) {
            Write-Verbose -Message "Processing Command"
            $ModifyRecord = {
                $SPItem[$field] = $setFieldValue
                $SPItem.SystemUpdate($false)
            }
            $RecordsManagement::BypassLocks($SPItem, $ModifyRecord)
        }
    } catch [Exception] {
        Write-Error $_.Exception | format-list -force
    } # end try to create a date
}

function Edit-HUSPMetadataFromXML {

    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [String]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [String]$list,
        [Parameter(Mandatory=$true,Position=3)]
        [String]$xpath,
        [Parameter(Mandatory=$true,Position=5)]
        [String]$field,
        [Parameter(Mandatory=$true,Position=6)]
        [String]$caml,
        [Parameter(Mandatory=$false,Position=7)]
        [String]$group="UF Fileplan",
        [Parameter(Mandatory=$false,Position=8)]
        [String]$set
    )
    
    #Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPField = $SPList.Fields[$field]
    $SPFieldType = $SPField.TypeAsString
    $RecordsManagement = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]
    
    $SPWeb.AllowUnsafeUpdates = $true
    
    $spQuery = New-Object Microsoft.SharePoint.SPQuery
    $camlQuery = Get-Content $caml -Raw
    $spQuery.RowLimit = 100
    $spQuery.Query = $camlQuery 

    do {
        $SPListItems = $SPList.GetItems($spQuery)
        $spQuery.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        
        foreach($SPItem in $SPListItems) {
            # Get current record information
            $SPItemId = $SPItem['_dlc_DocId'].ToString()
            Write-Host "----====++++Start Item $SPItemId++++====----" -ForegroundColor DarkGreen
            $SPItemArchivedMetadata = $SPItem["Archived Metadata"].ToString()
            # Write-Verbose $SPItemArchivedMetadata
            # Get field value information
            try {
                [xml]$SPItemXML = $SPItem["Archived Metadata"].ToString()
                # Devise a method using XPath and Namespaces to get any value in the archived metadata
                $SPXmlNs = $SPItemXML.DocumentElement.NamespaceURI
                # Write-Verbose -Message "XML Namespace is $SPXmlNs"
                $ns = @{ns0=$SPXmlNs}
                $SPParamXmlNode = Select-Xml -Xml $SPItemXML -xpath "//ns0:$xpath" -Namespace $ns | Select-Object -ExpandProperty Node
                # CHECKME - this seems to work with text and cdata but in case not we need to use either .'#text' or .'#cdata-section' 
                [String]$SPParamXmlValue = $SPParamXmlNode.InnerText
                $SPParamXmlValue = $SPParamXmlValue.Trim()
                Write-Verbose $SPParamXmlValue
                # Get the WISDOM archive string as well in case we need to look for some date into in there
                $SPPathXmlNode = Select-Xml -Xml $SPItemXML -xpath "//ns0:archiveurlstr" -Namespace $ns | Select-Object -ExpandProperty Node    
                [String]$SPPathXmlValue = $SPPathXmlNode.'#cdata-section'
                $SPPathXmlValue = $SPPathXmlValue.Trim()
            } catch [Exception]{
                    Write-Error $_.Exception | format-list -force
            }

            Switch ($SPFieldType) {
                "Boolean" {Write-Host "The field type is Boolean"}
                "Calculated" {Write-Host "The field type is Calculated"}
                "Choice" {Write-Host "The field type is Choice"}
                "Computed" {Write-Host "The field type is Computed"}
                "ContentTypeId" {Write-Host "The field type is ContentTypeId"}
                "Counter" {Write-Host "The field type is Counter"}
                "DateTime" {
                    Write-Verbose -Message "Field type is DateTime, searching '$SPParamXmlValue' for a date..."
                    Get-HUSPDateTimeValue -value $SPParamXmlValue -pathstr $SPPathXmlValue
                }
                "ExemptField" {Write-Host "The field type is ExemptField"}
                "File" {Write-Host "The field type is File"}
                "Guid" {Write-Host "The field type is Guid"}
                "Integer" {Write-Host "The field type is Integer"}
                "Lookup" {Write-Host "The field type is Lookup"}
                "LookupMulti" {Write-Host "The field type is LookupMulti"}
                "ModStat" {Write-Host "The field type is ModStat"}
                "Note" {Write-Host "The field type is Note"}
                "Number" {Write-Host "The field type is Number"}
                "TaxonomyFieldType" {
                    Write-Verbose -Message "Field type is TaxonomyFieldType"
                    Get-HUSPTaxonomyValue -value $SPParamXmlValue
                }
                "TaxonomyFieldTypeMulti" {Write-Host "The field type is TaxonomyFieldTypeMulti"}
                "Text" {Write-Host "The field type is Text"}
                "URL" {Write-Host "The field type is URL"}
                "User" {Write-Host "The field type is User"}
                default {Write-Host "The field type could not be determined"}
            } 
        } # end for each loop
    } while ($spQuery.ListItemCollectionPosition -ne $null)

    $SPWeb.AllowUnsafeUpdates = $false

    $SPWeb.Dispose()

    Write-Host "Remember that GB uses 'subjects' and not 'Subjects' in his Archive Metadata" -ForegroundColor Red

}