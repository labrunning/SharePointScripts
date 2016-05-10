Add-PSSnapin Microsoft.SharePoint.Powershell
$myServer = $env:COMPUTERNAME

If ($myServer -match "AZSPSTFD") {
    Write-Host "This is Azure - Server: $myServer"
    $myScriptFolder = "E:\scripts"
} Else {
    Write-Host "This is Unishare - Server: $myServer"
    $myScriptFolder = "D:\scripts"
}

Import-Module $myScriptFolder\Invoke-HUSPPublishJobs.ps1 -Force -Verbose
Import-Module $myScriptFolder\Invoke-HUSPRepublishContentTypes.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPRecordsUndeclared.ps1 -Force -Verbose
Import-Module $myScriptFolder\New-HUSPListView.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPDocumentLibraryDefaults.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPMetadataNavigation.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPComDocType.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPDocumentMetadata.ps1 -Force -Verbose
Import-Module $myScriptFolder\Get-HUSPDocumentValues.ps1 -Force -Verbose