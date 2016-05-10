<#
Title: Set modified and created by details
Author: Alex Brassington
Category: Proof of Concept Script
Description
This script is to show how to read, modify and otherwise manipulate the created by and modified by details on documents.
This is to enable correction of incorrect data as part of migrations. It is also useful to enable testing of retention policies.
#>
 
#Add the SharePoint snapin
Add-PSSnapin Microsoft.SharePoint.Powershell -ea SilentlyContinue
 
#set the web url and the list name to work upon
$url = "https://devunishare.hud.ac.uk/test/Test/"
$listName = "TestA"
$fileName = "Doc1.docx"
 
#Get the appropriate list from the web
$web = get-SPWeb $url
$list = $web.lists[$listName]
 
#Get the file using the filename
$item = $list.Items | ? {$_.Name -eq $fileName}
 
#Print out current Created by and Created date
Write-Output ("item created by {0} on {1}" -f $item["Author"].tostring(), $item["Created"] )
 
#Print out current Created by and Created date
Write-Output ("item last modified by {0} on {1}" -f $item["Editor"].tostring(), ($item["Modified"] -f "dd-MM-yyyy"))
 
#Set the created by values
$userLogin = "ad\cmsxsjg"
$dateToStore = Get-Date "10/02/1984"
 
$user = $web.EnsureUser($userLogin)
$userString = "{0};#{1}" -f $user.ID, $user.UserLogin.Tostring()
 
 
#Sets the created by field
$item["Author"] = $userString
$item["Created"] = $dateToStore
 
#Set the modified by values
$item["Editor"] = $userString
$item["Modified"] = $dateToStore
 
 
#Store changes without overwriting the existing Modified details.
$item.UpdateOverwriteVersion()

$web.dispose()