<#
    .SYNOPSIS
    Changes the content type of every item in a list.
    .DESCRIPTION
    This script will change every .docx in a list you specify to a content type you specify
    .PARAMETER url
    a valid SharePoint Site url
    .PARAMETER list
    a valid SharePoint list
    .PARAMETER newct
    a valid content type for the list
    .EXAMPLE
    Set-HUSPContentType
    .NOTES
    Warning!! the content type must be available on the list. There is no error checking in the script so if you don't know what it does, don't use it!
#>
function Set-HUSPContentType {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$list,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$newct,
    )

    $SPWeb = Get-SPWeb $url
    Write-Verbose "Begin changing content type of .docx documents..."
    $DocumentLibrary = $SPWeb.Lists[$list]
    $NewContentType = $SPWeb.AvailableContentTypes[$newct]

    Write-Verbose "Changing Content type of items"
    $Items = $DocumentLibrary.Items
    $NewContentTypeID = $NewContentType.id
    ForEach ($Item in $Items) {
        If ($Item["ContentTypeId"] -ne $NewContentTypeID) {
            If ($DocumentLibrary.ForceCheckout -eq $true) {
                Write-Verbose "Item needs to be checked out"
                $Item.checkout()
            }
            If ($Item.Name -Like "*.docx") {
                $Item["ContentTypeId"] = $NewContentTypeID
                $Item.Update()
            }
            Write-Verbose "$Item.Name Updated"
            If ($DocumentLibrary.ForceCheckout -eq $true) {
                Write-Verbose "Item is being checked in with Major Version and comment"
                $Item.CheckIn("Corrected content type", [Microsoft.SharePoint.SPCheckinType]::MajorCheckIn)
            }
        }
    }
}