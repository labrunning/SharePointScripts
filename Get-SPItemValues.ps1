function Get-SPItemValues {
    #Ask for the web, list and item names
    $WebName = Read-Host "Please enter the web address:"
    $ListName = Read-Host "Please enter the list or library name:"
    $ItemName = Read-Host "Please enter the item title or file name:" 

    #Set up the object variables
    $web = Get-SPWeb $WebName
    $list = $web.Lists[$ListName]
    [string]$queryString = $null 

    #Check if the item is a file or list item and run a different query accordingly
    if ($list.BaseType -eq "DocumentLibrary") {
        $queryString = "<Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='File'>" + $ItemName + "</Value></Eq></Where>"
    }
    else
    {
        $queryString = "<Where><Eq><FieldRef Name='Title' /><Value Type='Text'>" + $ItemName + "</Value></Eq></Where>"
    } 

    #Create the CAML query to find the item
    $query = New-Object Microsoft.SharePoint.SPQuery
    $query.Query = $queryString
    $item = $list.GetItems($query)[0] 

    #Walk through each column associated with the item and
    #output its display name, internal name and value to a new PSObject
    $item.Fields | foreach { 
        $fieldValues = @{
            "Display Name" = $_.Title
            "Internal Name" = $_.InternalName
            "Value" = $item[$_.InternalName]
        }
        New-Object PSObject -Property $fieldValues | Select @("Display Name","Internal Name","Value")
    } 

    #Dispose of the Web object
    $web.Dispose()
}
