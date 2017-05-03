<#
    ################################################################
    .Synopsis
     A brief outline of what the script does
    .DESCRIPTION
     A more detailed description of what the script does
    .Parameter url
     A description of the url parameter
    .Parameter list
     A description of the list parameter
    .Parameter caml
     A description of the caml parameter
    .OUTPUTS
     A description of what the script outputs
    .EXAMPLE 
     An example of the command in use
    ################################################################
#>

function Delete-HUSPListItems {

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

    $SPWeb = Get-SPWeb $url
    $SPList = $SPWeb.Lists[$list] 
    
    $SPQuery = new-object Microsoft.SharePoint.SPQuery 
    # I'm wanting to delete lots with this, so let's go got the max! 
    $SPQuery.RowLimit = 5000 
    $camlQuery = Get-Content $caml -Raw
    $SPQuery.Query =  $camlQuery 
    
    do { 
        $SPListItems = $SPList.GetItems($SPQuery) 
        $SPQueryCount = $SPListItems.Count
        $SPQuery.ListItemCollectionPosition = $SPListItems.ListItemCollectionPosition
        $batchRemove = '<?xml version="1.0" encoding="UTF-8"?><Batch>'    
        $command = '<Method><SetList Scope="Request">' +   
            $SPList.ID +'</SetList><SetVar Name="ID">{0}</SetVar>' +   
            '<SetVar Name="Cmd">Delete</SetVar></Method>'    
        foreach ($item in $SPListItems) {
            $itemId = $item.Id
            Write-Verbose -message "Adding item $itemId to batch"
            $batchRemove += $command -f $item.Id;   
        }   
        $batchRemove += "</Batch>";    
         
        if ($PSCmdlet.ShouldProcess("Batch Delete on $SPQueryCount items")) {
            $SPList.ParentWeb.ProcessBatchData($batchRemove) | Out-Null 
        }
        $SPList.Update()
    }
    while ($SPQuery.ListItemCollectionPosition -ne $null)
     
    ## Dispose SPWeb object, it's just good manners 
    $SPWeb.Dispose()       

}