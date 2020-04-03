##[Ps1 To Exe]
##
##Kd3HDZOFADWE8uK1
##Nc3NCtDXThU=
##Kd3HFJGZHWLWoLaVvnQnhQ==
##LM/RF4eFHHGZ7/K1
##K8rLFtDXTiW5
##OsHQCZGeTiiZ4dI=
##OcrLFtDXTiW5
##LM/BD5WYTiiZ4tI=
##McvWDJ+OTiiZ4tI=
##OMvOC56PFnzN8u+Vs1Q=
##M9jHFoeYB2Hc8u+Vs1Q=
##PdrWFpmIG2HcofKIo2QX
##OMfRFJyLFzWE8uK1
##KsfMAp/KUzWJ0g==
##OsfOAYaPHGbQvbyVvnQX
##LNzNAIWJGmPcoKHc7Do3uAuO
##LNzNAIWJGnvYv7eVvnQX
##M9zLA5mED3nfu77Q7TV64AuzAgg=
##NcDWAYKED3nfu77Q7TV64AuzAgg=
##OMvRB4KDHmHQvbyVvnQX
##P8HPFJGEFzWE8tI=
##KNzDAJWHD2fS8u+Vgw==
##P8HSHYKDCX3N8u+Vgw==
##LNzLEpGeC3fMu77Ro2k3hQ==
##L97HB5mLAnfMu77Ro2k3hQ==
##P8HPCZWEGmaZ7/K1
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdZQRXWtkkz3oDUW6ZfcRWfoAsO4CUAkVK/oI8vzVA+LJ
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
# 设置自动，删除永久路由
$net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
$status = $net_wmi.DHCPEnabled
$rp =Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\PersistentRoutes
if($rp.Property){
# 删除永久路由
    $name = $rp.Property
    "$(Get-Date) : 删除永久路由 $name" | Out-File .\net_setting.log -NoClobber -Append;
    Remove-ItemProperty -Path $rp.PSPath -name $rp.Property
}
if($status){
    "$(Get-Date) : DHCP状态为自动获取，不需要其他操作。" | Out-File .\net_setting.log -NoClobber -Append;
}else{
    while($status -eq $false){
        $net_wmi.enabledhcp(); # 设置ip为动态获取
        $netip=get-netipconfiguration
        foreach ($i in $netip){
            if ($i.InterfaceDescription -eq "Red Hat VirtIO Ethernet Adapter"){
            $nic = $i.InterfaceAlias # 网卡
             }
        }
        netsh interface ip set dns name=$nic source=dhcp; # 回滚dns为自动获取
        $net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
        $status = $net_wmi.DHCPEnabled
        if($status){
            "$(Get-Date) : DHCP状态设置为自动获取。" | Out-File .\net_setting.log -NoClobber -Append;
            }
    }
}