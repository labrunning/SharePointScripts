$SPAssignment = Start-SPAssignment
$web = Get-SPWeb https://devunishare.hud.ac.uk/unifunctions/committees/University-Committees -AssignmentCollection $spAssignment
$list = $web.lists["University Health and Safety Committee"].items
foreach ($item in $list)
{
	$IsRecord = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::IsRecord($Item)
	if ($IsRecord -eq $true){
		Write-Host "Undeclared $($item.Title)"
		[Microsoft.Office.RecordsManagement.RecordsRepository.Records]::UndeclareItemAsRecord($Item)
	}
    $list.AllowDeletion = $true
    $list.Update()
}
Stop-SPAssignment $SPAssignment
