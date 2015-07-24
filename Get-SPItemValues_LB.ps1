#Ask for the web, list and item names
$WebName = Read-Host "Please enter the web address:"
$ListName = Read-Host "Please enter the list or library name:"
#Set up the object variables
$web = Get-SPWeb $WebName
$list = $web.Lists[$ListName]
$item = return $list.GetItems()

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