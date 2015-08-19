param (
    [string]$url,
    [string]$list,
    [string]$item
)
$w = get-spweb $url
$l = $w.lists[$list]
$i = $l.GetItemById($item)
$s = New-Object Microsoft.SharePoint.SPSite($w.site.id, $i.File.LockedByUser.UserToken)
$w = $s.OpenWeb($w.id)
$l = $w.lists[$list]
$i = $l.GetItemById($item)
$i.File.ReleaseLock($i.File.LockId)
