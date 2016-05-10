<#
    .Synopsis
     Does something with the change records in SharePoint
    .DESCRIPTION
     I cannot remember exactly what this does but it was something to do with the change records being FUBAR
    .Parameter web
      The Web Application
    .Parameter list
      The list to act on
    .OUTPUTS
      This is a description of what the script outputs
    .EXAMPLE 
      My-Script -web -list
      Does what the script does
    .LINK
      A link (usually a link to where I stoled the script from)
#>

function Set-HUSPChangeRecordCopy {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$sourcelist,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$destlist
    
    )
        
    $SPWeb = Get-SPWeb $url
    $SPSourceList = $SPWeb.Lists[$sourcelist]
    $SPDestinationList = $SPWeb.Lists[$destlist]

    # Get the maximum number of change records currently in the source list
    [string]$queryString = $null 
    $queryString = "<OrderBy><FieldRef Name='Change_x0020_No' Ascending='FALSE'/></OrderBy>"
    $query = New-Object Microsoft.SharePoint.SPQuery
    $query.Query = $queryString
    $item = $SPSourceList.GetItems($query)[0]
    
    $SPSourceMax = $item['Change_x0020_No']

    Write-Host There are $SPSourceMax records in the source 

    $i = 165

    Do {
        # $i
        # query the source
        [string]$SqueryString = $null 
        $SqueryString = "<Where><Eq><FieldRef Name='Change_x0020_No' /><Value Type='Number'>" + $i + "</Value></Eq></Where>"
        $Squery = New-Object Microsoft.SharePoint.SPQuery
        $Squery.Query = $SqueryString
        Try {
            $Sitem = $SPSourceList.GetItems($Squery)[0]   
            # Get all the field values
            [Double]$SourceChangeNo = $Sitem["Change No"]
            [DateTime]$SourceCreated = $Sitem["Created"]
            [DateTime]$SourceDate = $Sitem["Date"]
            $SourceDescription = $Sitem["Description"]
            $SourceDetails = $Sitem["Details"]
            $SourceEquipment = $Sitem["Equipment"]
            $SourceITSystem = $Sitem["IT System"]
            [DateTime]$SourceModified = $Sitem["Modified"]
            $SourceReason = $Sitem["Reason"]
            $SourceRecorder = $Sitem["Recorder"]
            $SourceResult = $Sitem["Result"]
            $SourceRFCNo = $Sitem["RFC No"]
            $SourceSystem = $Sitem["System"]
            $SourceTime = $Sitem["Time"]
            $SourceCreatedBy = $Sitem["Created By"]
            $SourceModifiedBy = $Sitem["Modified By"]

            # Write-Host Record $i has description: $SPSourceItemDesc
            # Copy this record to the destination list
            $Ditem = $SPDestinationList.AddItem()
            # Copy all the fields in
            $Ditem["Change No"] = $SourceChangeNo
            $Ditem["Created"] = $SourceCreated
            $Ditem["Date"] = $SourceDate
            $Ditem["Description"] = $SourceDescription
            $Ditem["Details"] = $SourceDetails
            $Ditem["Equipment"] = $SourceEquipment

            # Set the IT System from a lookup list
            $DLookupField = $SPDestinatioList.Fields["IT System"] -as [Microsoft.SharePoint.SPFieldLookup]
            $DLookupList = $SPDestinatioList.Lists[[Guid]$DLookupField.LookupList]
            $DSourceField = $DLookupField.LookupField
            $DLookupItem = $DLookupList.Items | Where-Object {$_.Name -eq $ITSystem }
            $DLookupString = ($DLookupItem.ID).ToString() + ";#" + ($DLookupItem.Name).ToString()
            $Ditem["IT System"] = $DLookupString

            $Ditem["Modified"] = $SourceModified
            $Ditem["Reason"] = $SourceReason
            $Ditem["Recorder"] = $SPWeb.EnsureUser($SourceRecorder)
            $Ditem["Result"] = $SourceResult
            $Ditem["RFC No"] = $SourceRFCNo
            $Ditem["System"] = $SourceSystem
            $Ditem["Time"] = $SourceTime
            $Ditem["Created By"] = $SPWeb.EnsureUser($SourceCreatedBy)
            $Ditem["Modified By"] = $SPWeb.EnsureUser($SourceModifiedBy)

        } Catch {
            Write-Host I guess we deleted record $i ! 
            # So here we would create a record and mark it with something to delete 
        } 
        $i++
    # } While ($i -le 174)
    } While ($i -le $SPSourceMax)

    $SPWeb.Dispose()
}