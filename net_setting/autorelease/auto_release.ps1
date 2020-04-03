<#
用途：检测是否获取ip,如果失败则针对网卡release
#>

$net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
$CIP = $net_wmi.IPAddress[0]
$status = $net_wmi.DHCPEnabled
$netip=get-netipconfiguration
foreach ($i in $netip){
    if ($i.InterfaceDescription -eq "Red Hat VirtIO Ethernet Adapter"){
        $nic = $i.InterfaceAlias # 网卡
     }
 }
 "$(Get-Date) :网卡 $nic 的IP地址为$CIP" | Out-File .\net_setting.log -NoClobber -Append;
 #检验ip是否能成功获取
 while($CIP.ToString() -match "169.*"){
        "$(Get-Date) :网卡 $nic的IP地址未获取成功，正在重新获取IP地址中" | Out-File .\net_setting.log -NoClobber -Append;
        
        $release_log = ipconfig /release $nic;
        Start-Sleep -Seconds 2;
        "$(Get-Date) :release执行完毕  $release_log " | Out-File .\net_setting.log -NoClobber -Append;
        $renew_log = ipconfig.exe /renew $nic;
        "$(Get-Date) :renew执行完毕 $renew_log " | Out-File .\net_setting.log -NoClobber -Append;
        Start-Sleep -Seconds 1;
        $net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
        $CIP = $net_wmi.IPAddress[0]
    }
