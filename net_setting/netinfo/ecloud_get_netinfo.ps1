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
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdZQRXWtkkz3oDUW6ZfcRWfoAsO4WUAkVIfcf67zWFKmsXadq
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
"-----------------------------$(Get-Date) ：当前网络状态---------------------------------------------" | Out-File .\net_setting.log -NoClobber -Append;

ipconfig /all | Out-File .\net_setting.log -NoClobber -Append;

"-----------------------------$(Get-Date) ：当前路由配置---------------------------------------------" | Out-File .\net_setting.log -NoClobber -Append;

route print -4 | Out-File .\net_setting.log -NoClobber -Append;

"-----------------------------$(Get-Date) ：检测是否正常联网---------------------------------------------" | Out-File .\net_setting.log -NoClobber -Append;


function detection {
    if (Test-Connection -Count 1 www.baidu.com -Quiet)
    {
        echo "$(Get-Date) connect ok"
     }else{
        echo "$(Get-Date) connect to baidu failed"

        echo " "
        echo "ping 14.215.177.39 : "
        ping 14.215.177.39

        echo " "
        echo "ping 网关： "
        $net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
        ping $net_wmi.DefaultIPGateway[0]

        echo " "
        echo "adapter: "
        ipconfig /all

        echo " "
        echo "adapter: "
        Get-NetAdapter | Select-Object -Property Name,InterfaceDescription,Status

        echo " "
        echo "dns: "
        Get-DnsClientServerAddress | Select-Object -ExpandProperty ServerAddresses

        echo " "
        echo "traceroute: "
        tracert 114.114.114.114
        }
    }


function log_proc {

$log_path = ".\net_setting.log"
$log_temp_path = ".\net_setting_temp.log"
Get-Content $log_path -Tail 5000 | Out-File $log_temp_path
Remove-Item $log_path
Rename-Item -Path $log_temp_path -NewName "net_setting.log"

}

detection | Out-File .\net_setting.log -NoClobber -Append;
log_proc