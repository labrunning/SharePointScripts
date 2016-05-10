    <#
    ################################################################
    .Synopsis
     Sets the date of a committee record
    .DESCRIPTION
     Sets the committee date for a committee document that has been declared a record
    .Parameter url
     A valid SharePoint Web Site URL
    .Parameter list
     A valid SharePoint Document Library Title
    .Parameter ID
     A valid document ID of the record that needs changing (short version)
    .Parameter date
     A valid date in 09/24/2016 format (mm/dd/yyyy - don't ask me why it has to be the american format!) 
    .OUTPUTS
     Changes the committee date of a record in the document library
    .EXAMPLE 
     Set-HUSPCommitteeRecordDate -url https://unishare.hud.ac.uk/unifunctions/COM/University-Committees -list "Audit Committee" -ID 12 -comdate 09/24/2016
     - sets the committee date of Record 12 to 24th September 2016 
    ################################################################
    #>
    
function Set-HUSPCommitteeRecordDate {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$list,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$ID,
    [Parameter(Mandatory=$True,Position=4)]
    [datetime]$comdate
    )
        
    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list]
    $SPListItems = $SPList.Items

    $SPWeb.AllowUnsafeUpdates = $true

    ForEach($item in $SPListItems | Where {$_.'ID' -eq $ID } ) {
        $filename = $item['LinkFilename']
        $committeeDate = Get-Date($comdate)
        $ModifyRecord = {
            $item['Committee_x0020_Date'] = $committeeDate
            $item.SystemUpdate($false)
        }
        [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::BypassLocks($item, $ModifyRecord)
        Write-Verbose -message "$filename now has committee date of $committeeDate"
    }

    $SPWeb.AllowUnsafeUpdates = $false
    $SPWeb.Dispose()

}