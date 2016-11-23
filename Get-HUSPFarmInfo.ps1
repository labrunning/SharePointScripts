function Get-HUSPFarmInfo {

    $servers = Get-SPServer

    # Loop through all servers in the Farm
    foreach($server in $servers)
    {
        $serverName = $server.DisplayName
        Write-Host $serverName -ForegroundColor "Black" -BackgroundColor "Yellow"
        # Get SharePoint services running
        $servicesRunning = $server.ServiceInstances | Where{$_.Status -eq "Online" -and $_.Hidden -eq $False}
        Write-Host "SharePoint Services Running:" -ForegroundColor "Blue" -BackgroundColor "White"
        $servicesRunning | Select TypeName
        Write-Host "`n"
        # Get CPU Information
        $cpuInfo = Get-WmiObject -ComputerName $serverName -Class win32_processor | measure
        Write-Host "CPU Information:" -ForeGroundColor "Blue" -BackgroundColor "White"
        Write-Host "Number of Cores:" $cpuInfo.Count
        # Get Memory Information
        $memoryInfo = $object = Get-WmiObject -ComputerName $serverName -Class win32_computersystem
        $memoryInGB = $('{0:N2}' -f ($object.TotalPhysicalMemory/1024/1024/1024))
        Write-Host "Memory Information:" -ForeGroundColor "Blue" -BackgroundColor "White"
        Write-Host "RAM:" $memoryInGB "GB`n"     
        # Get Storage Information
        $drives = Get-WmiObject -ComputerName $serverName -Class win32_logicaldisk | Where {$_.DriveType -eq 3}
        Write-Host "Storage Information:" -ForeGroundColor "Blue" -BackgroundColor "White"
        foreach($drive in $drives)
        {
            $deviceId = $drive.DeviceId
            $totalSize = $('{0:N2}' -f ($drive.Size/1024/1024/1024))
            $freeSpace = $('{0:N2}' -f ($drive.FreeSpace/1024/1024/1024))
            $percentageFull = $('{0:N2}' -f ($freeSpace / $totalSize * 100))
            Write-Host $deviceId -ForeGroundColor "Green"
            Write-Host "Total Size:" $totalSize "GB"
            Write-Host "Free Space:" $freeSpace "GB"
            Write-Host "Percentage Full:" $percentageFull "%"
        }
        Write-Host "`n"
    }
}