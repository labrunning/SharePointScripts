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
    .PARAMETER xml
      A valid path to an XML file with a CAML query for the items you want to use
    .PARAMETER write
      A flag to state whether you want to actually write the values
    .OUTPUTS
      All the documents in the list will have the metadata term applied
    .EXAMPLE 
      Set-HUSPMetadataFromXML -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "University Health and Safety Committee" -xpath "subjects" -field "School of Education and Professional Development Subject" -xml ".\scripts\xml\caml_nullsubjects.xml" -group "UF Fileplan" -set "Subjects"
#>

function Edit-HUSPDefaultDate {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [String]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [String]$list,
        [Parameter(Mandatory=$true,Position=4)]
        [String]$xml
    )
    
    #Get destination site and list
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    
    $SPWeb.AllowUnsafeUpdates = $true
    
    $spQuery = New-Object Microsoft.SharePoint.SPQuery
    $caml = Get-Content $xml -Raw
    $spQuery.Query = $caml 

    do {
        $SPListItems = $SPList.GetItems($spQuery)
        $spQuery.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        foreach($SPItem in $SPListItems) {
            # Get current record information
            $SPItemId = $SPItem['_dlc_DocId'].ToString()
            Write-Output "---+++Start Item $SPItemId+++---" 
            # Get field value information
            try {
                [xml]$SPItemXML = $SPItem['Archived Metadata'].ToString()
                # Devise a method using XPath and Namespaces to get any value in the archived metadata
                $SPXmlNs = $SPItemXML.DocumentElement.NamespaceURI
                $ns = @{ns0=$SPXmlNs}
                $SPXmlNode = Select-Xml -Xml $SPItemXML -xpath "//ns0:archiveurlstr" -Namespace $ns | Select-Object -ExpandProperty Node    
                [String]$SPXmlNodeString = $SPXmlNode.'#text'
                [String]$SPXmlNodeString
                $SPArchiveString = $SPXmlNodeString.Split("|")
                If($SPArchiveString.Count -gt 1){
                    $title = "Select Path Section"
                    $message = "Choose the section of the old WISDOM path you want to use for the date`nUse '?' to view values"
                    $choices = @()
                    for ( $index = 0; $index -lt $SPArchiveString.Count; $index++ ) {
                        $choices += New-Object System.Management.Automation.Host.ChoiceDescription $index, $SPArchiveString[$index] 
                    }
                    $options = [System.Management.Automation.Host.ChoiceDescription[]]$choices
                    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
                    $SPArchiveString = $SPArchiveString[$result]
                }
                $SPArchiveString
            } catch [Exception]{
                    Write-Error $_.Exception | format-list -force
            } # try
        } # ForEach-Object
    } while ($null -ne $spQuery.ListItemCollectionPosition)

    $SPWeb.AllowUnsafeUpdates = $false

    $SPWeb.Dispose()

}