Add-PSSnapin Microsoft.SharePoint.Powershell
$myServer = $env:COMPUTERNAME
$currUser = $env:USERNAME

If ($myServer -match "AZSPSTFD") {
    Write-Output "This is Azure - Server: $myServer"
    Write-Output "You are logged in as $currUser"
    $myScriptFolder = "E:\scripts"
    $myDrive = "E:\"
} Else {
    Write-Output "This is Unishare - Server: $myServer"
    Write-Output "You are logged in as $currUser"
    $myScriptFolder = "D:\scripts"
    $myDrive = "D:\"
}

Import-Module $myScriptFolder\Get-HUSPDocumentValues.ps1 -Force -Verbose
Import-Module $myScriptFolder\Invoke-HUSPPublishJobs.ps1 -Force -Verbose
Import-Module $myScriptFolder\Invoke-HUSPRepublishContentTypes.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPCommitteeRecordDate.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPRecordsUndeclared.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPDocumentLibraryDefaults.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPMetadataNavigation.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPComDocType.ps1 -Force -Verbose
Import-Module $myScriptFolder\Set-HUSPDocumentMetadata.ps1 -Force -Verbose
Import-Module $myScriptFolder\New-HUSPListView.ps1 -Force -Verbose
Import-Module $myScriptFolder\New-HUSPContentOrganizerRule.ps1 -Force -Verbose
Import-Module $myScriptFolder\Get-HUSPArchivedMetadata.ps1 -Force -Verbose
Import-Module $myScriptFolder\Edit-HUSPMetadataFromXML.ps1 -Force -Verbose
Import-Module $myScriptFolder\Test-HUSPCamlQuery.ps1 -Force -Verbose
Import-Module $myScriptFolder\Unlock-HUSPFile.ps1 -Force -Verbose

Copy-Item $myScriptFolder\Profile.ps1 "C:\Windows\System32\WindowsPowerShell\v1.0" -Verbose

Set-Location $myDrive 