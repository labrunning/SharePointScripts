<# 
Stolen from: http://get-spscripts.com/2010/09/get-all-column-values-from-sharepoint.html
To show a specific field value, use like;
    Get-SPDocumentValues | Where-Object {$_."Display Name" -eq "Archived Metadata" }
#>
function Get-SPDocumentValues {
    #Ask for the web, list and item names
    $WebName = Read-Host "Please enter the web address:"
    $ListName = Read-Host "Please enter the list or library name:"
    $DocID = Read-Host "Please enter the Document ID:" 

    #Add the SharePoint snapin
    Add-PSSnapin Microsoft.SharePoint.Powershell -ea SilentlyContinue

    #Set up the object variables
    $web = Get-SPWeb $WebName
    $list = $web.Lists[$ListName]
    [string]$queryString = $null 

    # Filter on a Document ID
    $queryString = "<Where><Eq><FieldRef Name='_dlc_DocId' /><Value Type='Text'>" + $DocID + "</Value></Eq></Where>"

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