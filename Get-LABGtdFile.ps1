function Get-LABGtdFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=1)]
        [string]$dir="C:\Users\cmsxlb\Dropbox\Work\LIVE projects",
        [Parameter(Mandatory=$false,Position=2)]
        [string]$out="C:\Users\cmsxlb\Dropbox\Apps\Rainmeter\Skins\LuaTextFile\GTD\Test.txt"
    )

    # Exclude 'Done' and 'Cancelled'    
    $FilterItemsPattern = "- (?!.*(@done|@cancelled))"
    $i = 0

    # Get all the task items and trim for extra spaces    
    Get-ChildItem -Path $dir -Filter "~*.taskpaper" -Recurse | Select-String -Pattern $FilterItemsPattern | Select Line,FileName | ForEach-Object {
        $i++
        $_.Line.Trim()
    }
    $gtdCount = "GTD List: $i items"
    $gtdCount 
    
}

# Export it to a file that a rainmeter skin can read
$gtdOutFile = "C:\Users\cmsxlb\Dropbox\Apps\Rainmeter\Skins\LuaTextFile\GTD\Test.txt"
Get-LABGtdFile | Out-File -FilePath $gtdOutFile -encoding "utf8"