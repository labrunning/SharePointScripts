<# 
    .Synopsis
     Gets the size of a folder
    .DESCRIPTION
     Gets a human readable output for a folder on a drive
    .Parameter folder
      A valid folder path
    .OUTPUTS
      Outputs a human readable folder size
    .EXAMPLE 
      Get-HULBFolderSizes -folder B:\Scripts
#>

function Get-HULBFolderSizes {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$folder
    )

    $colItems = (Get-ChildItem $folder | Measure-Object -property length -sum)
    "$folder -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"

    $colItems = (Get-ChildItem $folder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
    foreach ($i in $colItems)
    {
        $subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum)
        $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
    }
}