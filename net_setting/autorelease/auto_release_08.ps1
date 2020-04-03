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
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdZQRXWtkkz3oDUW6ZfMHQfoqptQdUBw5Ks1buvzVA+LJ
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
<#
用途：判断虚机内网络是否为自动获取ip，如果是则将自动获取的ip设置为静态ip
#>
$net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
$CIP = $net_wmi.IPAddress[0]
$status = $net_wmi.DHCPEnabled
$nic = '本地连接 *'
# 判断ip是否已获取，未获取的话重新释放并获取ip
 while($CIP.ToString() -match "169.*"){
        "$(Get-Date) :IP地址未获取成功，正在重新获取IP地址中" | Out-File .\net_setting.log -NoClobber -Append;
        
        $release_log = ipconfig /release $nic;
        Start-Sleep -Seconds 2;
        "$(Get-Date) :release执行完毕  $release_log " | Out-File .\net_setting.log -NoClobber -Append;
        $renew_log = ipconfig.exe /renew $nic;
        "$(Get-Date) :renew执行完毕 $renew_log " | Out-File .\net_setting.log -NoClobber -Append;
        Start-Sleep -Seconds 1;
        $net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
        $CIP = $net_wmi.IPAddress[0]
    }