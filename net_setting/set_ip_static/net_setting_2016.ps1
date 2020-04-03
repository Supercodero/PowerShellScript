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
$netip=get-netipconfiguration
foreach ($i in $netip){
    if ($i.InterfaceDescription -eq "Red Hat VirtIO Ethernet Adapter"){
        $nic = $i.InterfaceAlias # 网卡
     }
 }

 #加载winapi
$ini = Add-Type -memberDefinition @"
[DllImport("Kernel32")]
public static extern long WritePrivateProfileString (
string section ,
string key , 
string val , 
string filePath );
[DllImport("Kernel32")]
public static extern int GetPrivateProfileString (
string section ,  
string key , 
string def , 
StringBuilder retVal ,  
int size , 
string filePath ); 
"@ -passthru -name MyPrivateProfileString -UsingNamespace System.Text
#定义配置
$section="net_setting"
$filePath="C:\net.ini"
$retVal=New-Object System.Text.StringBuilder(32)
#判断配置文件是否存在，不存在的话判断dncp是静态还是动态
if(Test-Path $filePath){
    $null=$ini::GetPrivateProfileString($section,"script_status","",$retVal,32,$filePath)
    $script_status = $retVal.ToString()
}else{
    if($status){
        $script_status = "0"
        $null=$ini::WritePrivateProfileString($section,"script_status",$script_status,$filePath)
    }else{
        $script_status = "1"
    }
}

# 判断DHCP是否为自动获取
"$(Get-Date) : 当前ip地址为 $CIP,DHCP状态为$status" | Out-File .\net_setting.log -NoClobber -Append;

if($script_status.CompareTo("0") -eq 0){
    # 状态码为0时表示配置文件中未保存内容，或保存内容不完整，需重新获取ip
    # 判断ip是否已获取，未获取的话重新释放并获取ip
    while($CIP.ToString() -match "169.*"){
        "$(Get-Date) :网卡 $nic 的IP地址未获取成功，正在重新获取IP地址中" | Out-File .\net_setting.log -NoClobber -Append;
        
        $release_log = ipconfig /release $nic;
        Start-Sleep -Seconds 3;
        "$(Get-Date) :release执行完毕  $release_log " | Out-File .\net_setting.log -NoClobber -Append;
        $renew_log = ipconfig.exe /renew $nic;
        "$(Get-Date) :renew执行完毕 $renew_log " | Out-File .\net_setting.log -NoClobber -Append;
        $net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
        $CIP = $net_wmi.IPAddress[0]
    }

    #ip成功获取后，获取路由设置,写入net.ini
    $arr_temp = Compare-Object -ReferenceObject (route print -4) -DifferenceObject (route print -4 | Select-String "在链路上") |Select-Object -ExpandProperty InputObject
    $i = $arr_temp.IndexOf("活动路由:") +3
    $j = $arr_temp.IndexOf("永久路由:") -1
    #$routes = @()
    $n = 0
    for($i;$i -lt $j;$i++){
        $r= $arr_temp[$i].Split(" ") | Select-Object -Unique
        $rr = $r[1]+"|"+$r[2]+"|"+$r[3]
        $section2 = "routes"
        $null=$ini::WritePrivateProfileString($section2,$n,$rr,$filePath)
    }

    
    # 自动获取ip后，重新获取一次子网掩码，网关，dns,写入net.ini
    $null=$ini::WritePrivateProfileString($section,"ip",$net_wmi.IPAddress[0],$filePath)
    $null=$ini::WritePrivateProfileString($section,"nic",$nic,$filePath)
    $null=$ini::WritePrivateProfileString($section,"gateway",$net_wmi.DefaultIPGateway[0],$filePath)
    $null=$ini::WritePrivateProfileString($section,"subnet_mask",$net_wmi.IPSubnet[0],$filePath)
    #dns单独保存在新section下
    $section3 = "DNS"
    $dnses = $net_wmi.DNSServerSearchOrder
    $n = 0
    foreach($dns in $dnses){
        $null=$ini::WritePrivateProfileString($section3,$n,$dns,$filePath)
        $n++;
    }
    $script_status = "-1"
    $null=$ini::WritePrivateProfileString($section,"script_status",$script_status,$filePath)
    "$(Get-Date) : 网络配置已写入配置文件" | Out-File .\net_setting.log -NoClobber -Append;
}

if($script_status.CompareTo("-1") -eq 0){
    # 状态码为1表示net.ini文件中已完整保存所有网络设置
    $n=20;
    $ip_status = $false;
    while($n -gt 0){
        # 从配置文件中读取各项配置信息
        $null=$ini::GetPrivateProfileString($section,"ip","",$retVal,32,$filePath)
        $CIP = $retVal.ToString()
        $null=$ini::GetPrivateProfileString($section,"nic","",$retVal,32,$filePath)
        $nic = $retVal.ToString()
        $null=$ini::GetPrivateProfileString($section,"gateway","",$retVal,32,$filePath)
        $gateway = $retVal.ToString()
        $null=$ini::GetPrivateProfileString($section,"subnet_mask","",$retVal,32,$filePath)
        $Subnet_mask = $retVal.ToString()
        $dnsarr = @()
        $section3 = "DNS"
        $n = 0
        while($n -ne -1){
            $null=$ini::GetPrivateProfileString($section3,$n,"",$retVal,32,$filePath)
            if($retVal.Length -eq 0){
                $n = -1
            }else{
                $dnsarr += $retVal.ToString()
                $n++;
            }
        }
        
        # 设置静态ip
        "$(Get-Date) : 设置网络 $nic 固化IP地址为 $CIP,子网掩码为 $Subnet_mask,网关为 $gateway, DNS为 $dnsarr" | Out-File .\net_setting.log -NoClobber -Append;
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
                    $net_wmi.enabledhcp(); # 回滚ip为动态获取
                    netsh interface ip set dns name=$nic source=dhcp; # 回滚dns为自动获取
                    $n = $n-1;
                    Start-Sleep -Seconds 5;
                }
            }else{
                $resultnum = $result2.ReturnValue;
                "$(Get-Date) : IP设置成功，但网关设置失败，错误码为：$resultnum." | Out-File .\net_setting.log -NoClobber -Append;
                $net_wmi.enabledhcp(); # 因为网关设置失败，设置ip为动态获取
                netsh interface ip set dns name=$nic source=dhcp; # 回滚dns为自动获取
                $n = $n-1;
                Start-Sleep -Seconds 5;
            }
        }else{
            $resultnum = $result1.ReturnValue
            "$(Get-Date) : IP设置失败，错误码为： $resultnum." | Out-File .\net_setting.log -NoClobber -Append;
            $net_wmi.enabledhcp(); # 因为网关设置失败，设置ip为动态获取
            netsh interface ip set dns name=$nic source=dhcp; # 回滚dns为自动获取
            $n = $n-1;
            Start-Sleep -Seconds 5;
        }
    }
    # 检验ip是否正确设置，防止空值出现
    Start-Sleep -Seconds 10;
    if($ip_status){
        $ip_status = $false;
        $nicstring = "以太网适配器 "+$nic+":"
        $test_first = (ipconfig|Select-Object).indexof($nicstring)
        $test_last = $test_first + 6
        $test_config = (ipconfig|Select-Object)[$test_first..$test_last]
        $test_ip = ($test_config|select-string "IPv4"|out-string).Split(":")[-1].Trim(" .-`t`n`r");
        if($test_ip.CompareTo($CIP) -eq 0){
            $test_subnet_mask = ($test_config|select-string "子网掩码"|out-string).Split(":")[-1].Trim(" .-`t`n`r");
            if($test_subnet_mask.CompareTo($Subnet_mask) -eq 0){
                $test_gateway = ($test_config|select-string "默认网关"|out-string).Split(":")[-1].Trim(" .-`t`n`r");
                if($test_gateway.CompareTo($gateway) -eq 0){
                    "$(Get-Date) : 检验静态IP设置成功。" | Out-File .\net_setting.log -NoClobber -Append;
                    $ip_status = $true;
                }else{
                    "$(Get-Date) : 检验静态IP，网关设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
                    $net_wmi.enabledhcp();
                    netsh interface ip set dns name=$nic source=dhcp # 回滚dns为自动获取
                }
            }else{
                "$(Get-Date) : 检验静态IP,子网掩码设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
                $net_wmi.enabledhcp();
                netsh interface ip set dns name=$nic source=dhcp # 回滚dns为自动获取
            }
        }else{
            "$(Get-Date) : 检验静态IP设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
            $net_wmi.enabledhcp();
            netsh interface ip set dns name=$nic source=dhcp # 回滚dns为自动获取
        }
    }
    
    #设置route
    if($ip_status){
        # 从配置文件中读取路由信息
        $n = 0
        $routes = @()
        $section2 = "routes"
        while($n -ne -1){
            $null=$ini::GetPrivateProfileString($section2,$n,"",$retVal,64,$filePath)
            if($retVal.Length -eq 0){
                $n = -1
            }else{
                $r = $retVal.ToString().Split("|");
                $routes += @{Target = $r[0] ; Mask = $r[1] ; Gateway = $r[2]}
                $n++;
            }
        }
        #设置route
        foreach($route in $routes){
            route -p add $route["Target"] mask $route["Mask"] $route["Gateway"]
        }
    
        #检测route是否获取成功
        $route_test = route print -4 | Select-Object
        $index = $route_test.IndexOf("永久路由:")+2
        $r_test = @()
        for($index;$index -lt ($route_test.count-1);$index++){
            $r= $route_test[$index].Split(" ") | Select-Object -Unique;
            $r_test += $r[1];
        }
        foreach($route in $routes){
            if($r_test -contains $route["Target"]){
                $targetip = $route["Target"]
                "$(Get-Date) : $targetip 永久路由设置成功" | Out-File .\net_setting.log -NoClobber -Append;
                "$(Get-Date) : 网路配置结束，删除配置文件" | Out-File .\net_setting.log -NoClobber -Append;
                Remove-Item $filePath
            }else{
                $targetip = $route["Target"]
                "$(Get-Date) : $targetip 永久路由设置失败，将回滚为动态IP模式。" | Out-File .\net_setting.log -NoClobber -Append;
                $net_wmi.enabledhcp();
                netsh interface ip set dns name=$nic source=dhcp # 回滚dns为自动获取
            }
        }
    }
}

if($script_status.CompareTo("1") -eq 0){
    "$(Get-Date) : 检测到虚机已为静态IP，不需要其他操作。" | Out-File .\net_setting.log -NoClobber -Append;
}
