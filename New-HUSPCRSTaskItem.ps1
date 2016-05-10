<#
    .Synopsis
     Adds a task to the CRS Task List
    .DESCRIPTION
     Adds a task to the CRS Service Requests lists, assigned to me and in the Unishare Support category
    .Parameter url
      The site where the task list lives
    .Parameter list
      The name of the task list
    .OUTPUTS
      A new task is added to the list
    .EXAMPLE 
      New-HUSPCRSTaskItem -url https://unishare.hud.ac.uk/cls/teams/it/cis/crs -list "CRS Service Requests" -taskname "Create an overegineered project initiation script"
      Adds a task called "Create an overegineered project initiation script"
    .LINK
      https://unishare.hud.ac.uk/cls/teams/it/cis/crs/CRS%20Service%20Requests
#>

function New-HUSPCRSTaskItem {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$url,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$list,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$taskname
    )
    
    $SPWeb = Get-SPWeb $url 
    $SPList = $SPWeb.Lists[$list]
    $SPTaskAssignedTo = "AD\cmsxlb"
    $SPTaskProject = "Unishare Development"
    
    $SPTask = $SPList.AddItem()
    $SPTask["Title"] = $taskname
    $SPTask["Project"] = $SPTaskProject
    $SPTask["AssignedTo"] = $SPWeb.EnsureUser($SPTaskAssignedTo)

    $SPTask.Update()
    
    $SPWeb.Dispose()    
}    