function Set-HUSPKtpContentType {

    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$caml
    )
      
    $mySPWeb = Get-SPWeb $url
    $mySPList = $mySPWeb.Lists[$list]
    $mySPKtpField = "School of Computing and Engineering KTP"
    $mySPField = $mySPList.Fields[$mySPKtpField]
    $mySPContentType = $mySPList.ContentTypes["School of Computing and Engineering KTP Committee"]
    $mySPContentTypeName = $mySPContentType.Name
    $mySPFieldType = $mySPField.TypeAsString
    $RecordsManagement = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]
    
    $mySPWeb.AllowUnsafeUpdates = $true
    
    $mySPQuery = New-Object Microsoft.SharePoint.SPQuery
    $myCamlQuery = Get-Content $caml -Raw
    $mySPQuery.Query = $myCamlQuery 

    do {
        $mySPListItems = $mySPList.GetItems($mySPQuery)
        $mySPQuery.ListItemCollectionPosition = $mySPListItems.ListItemCollectionPosition
        
        foreach($mySPItem in $mySPListItems) {
            $mySPItemId = $mySPItem.Id
            if ($mySPItem["ContentTypeId"] -ne $mySPContentType.Id) {
                # change the content type Id
                If ($PSCmdlet.ShouldProcess($mySPItemId, "Changing content type to $mySPContentTypeName")) {
                    $UpdateItemCt = {
                        $mySPItem["ContentTypeId"] = $mySPContentType.Id
                        $mySPItem.SystemUpdate($false)
                    }
                    try {
                        $RecordsManagement::BypassLocks($mySPItem, $UpdateItemCt)
                    } catch [Exception]{
                        Write-Error "Error changing item $mySPItemId content type"
                        Write-Error $_.Exception | format-list -force
                    }
                }   
            } else {
                Write-Host "Content Type is already set for item $mySPItemId"
            }
            # get the archiveurlstr from the archived metadata
            $mySPItemArchivedMetadata = $mySPItem["Archived Metadata"].ToString()
            [xml]$mySPItemXml = $mySPItem["Archived Metadata"].ToString()
            $mySPXmlNs = $mySPItemXml.DocumentElement.NamespaceURI
            $ns = @{ns0=$mySPXmlNs}
            $mySPPathXmlNode = Select-Xml -Xml $mySPItemXml -XPath "//ns0:archiveurlstr" -Namespace $ns | Select-Object -ExpandProperty Node
            [string]$mySPPathXmlValue = $mySPPathXmlNode.'#cdata-section'
            $mySPPathItems = $mySPPathXmlValue -split '\|'
            $mySPPathItem = $mySPPathItems[7].Replace("-"," ")
            # Match the path to the KTP entries in the term store
            $mySPTaxonomySession = Get-SPTaxonomySession -Site $mySPWeb.Site
            $mySPTermStore = $mySPTaxonomySession.TermStores[0]
            $mySPTermStoreGroup = $mySPTermStore.Groups["UF Fileplan"]
            $mySPTermSet = $mySPTermStoreGroup.TermSets["Knowledge Transfer Partners"]
            $mySPTerm = $mySPTermSet.GetTerms($mySPPathItem,$true)
            $mySPTermValueGuid = $mySPTerm.Id
            $mySPTermValueName = $mySPTerm.Name
            Write-Verbose "Guid is $mySPTermValueGuid Name is $mySPTermValueName"
            $mySPTaxonomyField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$mySPList.Fields[$mySPKtpField]
            [Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue]$mySPTaxonomyFieldValue = New-Object Microsoft.SharePoint.Taxonomy.TaxonomyFieldValue($mySPTaxonomyField)    
            $mySPTaxonomyFieldValue.PopulateFromLabelGuidPair([Microsoft.SharePoint.Taxonomy.TermSet]::NormalizeName($mySPPathItem) + "|" + $mySPTermValueGuid)
            $setFieldValue = $mySPTaxonomyFieldValue.ValidatedString
            Write-Verbose "Metadata value is '$setFieldValue' for field $mySPKtpField"
            If ($PSCmdlet.ShouldProcess($mySPItemId, "Setting KTP metadata to $mySPTermValueName")) {
                $ModifyRecord = {
                    $mySPItem[$mySPKtpField] = $setFieldValue
                    $mySPItem.SystemUpdate($false)
                }
                try {
                    $RecordsManagement::BypassLocks($mySPItem, $ModifyRecord)
                } catch [Exception]{
                    Write-Error "Error writing metadata to item $mySPItemId"
                    Write-Error $_.Exception | format-list -force
                }
            }
        }
    } while ($null -ne $mySPQuery.ListItemCollectionPosition)

    $mySPWeb.AllowUnsafeUpdates = $false

    $mySPWeb.Dispose()
}