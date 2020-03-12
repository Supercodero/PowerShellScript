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
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdZQRXWtkkz3oDUW6ZfwXQcoGscUFXBMtEKJTrLfIHoc=
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
<#
用途：判断虚机内网络是否为自动获取ip，如果是则将自动获取的ip设置为静态ip
#>
$net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"
$CIP = (ipconfig|select-string "IPv4"|out-string).Split(":")[-1].Trim(" .-`t`n`r")
$status = $net_wmi.DHCPEnabled
$dnsarr = $net_wmi.DNSServerSearchOrder
<#
$netip=get-netipconfiguration
foreach ($i in $netip){
    if ($i.InterfaceDescription -eq "Red Hat VirtIO Ethernet Adapter"){
        $nic = $i.InterfaceAlias # 网卡
        $dnsarr = $i.DNSServer.ServerAddresses # DNS
     }
 }
 #>
"$(Get-Date) : 当前ip地址为 $CIP,DHCP状态为$status" | Out-File .\net_setting.log -NoClobber -Append;
# 判断DHCP是否为自动获取
if($status){
    # 判断ip是否已获取，未获取的话重新释放并获取ip
    while($CIP.ToString() -match "169.*"){
        "$(Get-Date) :网卡 $nic的IP地址未获取成功，正在重新获取IP地址中" | Out-File .\net_setting.log -NoClobber -Append;
        
        $release_log = ipconfig /release $nic;
        Start-Sleep -Seconds 3;
        "$(Get-Date) :release执行完毕  $release_log " | Out-File .\net_setting.log -NoClobber -Append;
        $renew_log = ipconfig.exe /renew $nic;
        "$(Get-Date) :renew执行完毕 $renew_log " | Out-File .\net_setting.log -NoClobber -Append;
        $CIP = (ipconfig|select-string "IPv4"|out-string).Split(":")[-1].Trim(" .-`t`n`r")
        Start-Sleep -Seconds 3;
    }
    # 自动获取ip后，重新获取一次子网掩码，网关，dns
    $gateway=(ipconfig|select-string "默认网关"|out-string).Split(":")[-1].Trim(" .-`t`n`r")
    $Subnet_mask = (ipconfig|select-string "子网掩码"|out-string).Split(":")[-1].Trim(" .-`t`n`r")
    # 设置静态ip
    "$(Get-Date) : 设置固化IP地址为 $CIP,子网掩码为 $Subnet_mask,网关为 $gateway, dns 为 $dnsarr" | Out-File .\net_setting.log -NoClobber -Append;
    $result1 = $net_wmi.EnableStatic($CIP,$Subnet_mask)
    if($result1.ReturnValue -eq 0){
        $result2 = $net_wmi.setGateways($gateway)
        if($result2.ReturnValue -eq 0){
            $result3 =$net_wmi.SetDNSServerSearchOrder($dnsarr)
            if($result3.ReturnValue -eq 0 -or $result3.ReturnValue -eq 96 ){
                "$(Get-Date) :  静态IP设置成功。" | Out-File .\net_setting.log -NoClobber -Append;
            }else{
                $resultnum = $result3.ReturnValue;
                "$(Get-Date) : IP设置成功，但DNS设置失败，错误码为 $resultnum." | Out-File .\net_setting.log -NoClobber -Append;
            }
        }else{
            $resultnum = $result2.ReturnValue
            "$(Get-Date) : IP设置成功，但网关设置失败，错误码为：$resultnum." | Out-File .\net_setting.log -NoClobber -Append;
            $net_wmi.enabledhcp() # 因为网关设置失败，设置ip为动态获取
        }
    }else{
        $resultnum = $result1.ReturnValue
        "$(Get-Date) : IP设置失败，错误码为： $resultnum." | Out-File .\net_setting.log -NoClobber -Append;
    }
}else{
    "$(Get-Date) : DNCP为关闭状态，不需要其他操作。" | Out-File .\net_setting.log -NoClobber -Append;
}
