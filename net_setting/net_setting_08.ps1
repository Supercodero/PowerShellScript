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
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdZQRXWtkkz3oDUW6ZfwXQcoGscUFXBMtEKBbs+TvDum6TKUEl+cxbv2Lxg==
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
<#$netip=get-netipconfiguration
foreach ($i in $netip){
    if ($i.InterfaceDescription -eq "Red Hat VirtIO Ethernet Adapter"){
        $nic = $i.InterfaceAlias # 网卡
     }
 }
 #>

"$(Get-Date) : 当前ip地址为 $CIP,DHCP状态为$status" | Out-File .\net_setting.log -NoClobber -Append;
# 判断DHCP是否为自动获取
if($status){
    # 判断ip是否已获取，未获取的话重新释放并获取ip
    while($CIP.ToString() -match "169.*"){
        "$(Get-Date) :网卡 $nic的IP地址未获取成功，正在重新获取IP地址中" | Out-File .\net_setting.log -NoClobber -Append;
        
        $release_log = ipconfig /release;
        Start-Sleep -Seconds 3;
        "$(Get-Date) :release执行完毕  $release_log " | Out-File .\net_setting.log -NoClobber -Append;
        $renew_log = ipconfig.exe /renew;
        "$(Get-Date) :renew执行完毕 $renew_log " | Out-File .\net_setting.log -NoClobber -Append;
        $net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
        $CIP = $net_wmi.IPAddress[0]
        Start-Sleep -Seconds 3;
    }

    #ip成功获取后，获取路由设置
    $arr_temp = Compare-Object -ReferenceObject (route print -4) -DifferenceObject (route print -4 | Select-String "在链路上") |Select-Object -ExpandProperty InputObject
    $temp = 0
    foreach($arr_item in $arr_temp){
        if($arr_item.compareTo("活动路由:") -eq 0){
            $i = $temp + 3;
        }elseif($arr_item.compareTo("永久路由:") -eq 0){
            $j = $temp - 1;
        }
        $temp++;
    }
    $routes = @()
    for($i;$i -lt $j;$i++){
        $r= $arr_temp[$i].Split(" ") | Select-Object -Unique
        $routes += @{Target = $r[1] ; Mask = $r[2] ; Gateway = $r[3]}
    }

    $n=20;
    $ip_status = $false;
    while($n -gt 0){
        # 自动获取ip后，重新获取一次子网掩码，网关，dns
        $gateway=$net_wmi.DefaultIPGateway[0]
        $Subnet_mask = $net_wmi.IPSubnet[0]
        $dnsarr = $net_wmi.DNSServerSearchOrder
        # 设置静态ip
        "$(Get-Date) : 设置网络 $nic 固化IP地址为 $CIP,子网掩码为 $Subnet_mask,网关为 $gateway, dns 为 $dnsarr" | Out-File .\net_setting.log -NoClobber -Append;
        $result1 = $net_wmi.EnableStatic($CIP,$Subnet_mask)
        if($result1.ReturnValue -eq 0){
            $result2 = $net_wmi.setGateways($gateway)
            if($result2.ReturnValue -eq 0){
                $result3 =$net_wmi.SetDNSServerSearchOrder($dnsarr)
                if($result3.ReturnValue -eq 0 -or $result3.ReturnValue -eq 96 ){
                    "$(Get-Date) :  静态IP设置成功。" | Out-File .\net_setting.log -NoClobber -Append;
                    $ip_status = $true;
                    $n = 0;
                }else{
                    $resultnum = $result3.ReturnValue;
                    "$(Get-Date) : IP设置成功，但DNS设置失败，错误码为 $resultnum." | Out-File .\net_setting.log -NoClobber -Append;
                    $n = $n-1

                }
            }else{
                $resultnum = $result2.ReturnValue
                "$(Get-Date) : IP设置成功，但网关设置失败，错误码为：$resultnum." | Out-File .\net_setting.log -NoClobber -Append;
                $net_wmi.enabledhcp() # 因为网关设置失败，设置ip为动态获取
                $n = $n-1
            }
        }else{
            $resultnum = $result1.ReturnValue
            "$(Get-Date) : IP设置失败，错误码为： $resultnum." | Out-File .\net_setting.log -NoClobber -Append;
            $n = $n-1
        }
    }
    # 检验ip是否正确设置，防止空值出现
    Start-Sleep -Seconds 10;
    if($ip_status){
        $ip_status = $false;
        $test_netwmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
        $test_ip = $test_netwmi.IPAddress[0]
        if($test_ip.CompareTo($CIP) -eq 0){
            $test_subnet_mask = $test_netwmi.IPSubnet[0];
            if($test_subnet_mask.CompareTo($Subnet_mask) -eq 0){
                $test_gateway = $test_netwmi.DefaultIPGateway[0];
                if($test_gateway.CompareTo($gateway) -eq 0){
                    "$(Get-Date) : 检验静态IP设置成功。" | Out-File .\net_setting.log -NoClobber -Append;
                    $ip_status = $true;
                }else{
                    "$(Get-Date) : 检验静态IP，网关设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
                    $net_wmi.enabledhcp();
                }
            }else{
                "$(Get-Date) : 检验静态IP,子网掩码设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
                $net_wmi.enabledhcp();
            }
        }else{
            "$(Get-Date) : 检验静态IP设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
            $net_wmi.enabledhcp();
        }
    }
    
    #设置route
    if($ip_status){
        foreach($route in $routes){
            route -p add $route["Target"] mask $route["Mask"] $route["Gateway"]
        }
    
    #检测route是否获取成功
    $route_test = route print -4 | Select-Object
    $temp = 0
    foreach($route_test_item in $route_test){
        if($route_test_item.compareTo("永久路由:") -eq 0){
            $index = $temp + 2
        }
        $temp++;
    }
    $r_test = @()
    for($index;$index -lt ($route_test.count-1);$index++){
        $r= $route_test[$index].Split(" ") | Select-Object -Unique;
        $r_test += $r[1];
    }
    foreach($route in $routes){
        if($r_test -contains $route["Target"]){
            $targetip = $route["Target"]
            "$(Get-Date) : $targetip 永久路由设置成功" | Out-File .\net_setting.log -NoClobber -Append;
        }else{
            $targetip = $route["Target"]
            "$(Get-Date) : $targetip 永久路由设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
            $net_wmi.enabledhcp();
        }
    }
}
}else{
    "$(Get-Date) : DHCP为关闭状态，不需要其他操作。" | Out-File .\net_setting.log -NoClobber -Append;
}
