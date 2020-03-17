##[Ps1 To Exe]
##
##Kd3HDZOFADWE8uK1
##Nc3NCtDXThU=
##Kd3HFJGZHWLWoLaVvnQnhQ==
##LM/RF4eFHHGZ7/K1
##K8rLFtDXTiW5
##OsHQCZGeTiiZ4NI=
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
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdbsBXVtanzvuC1meUfcRXqVG5YdfUAUvTw==
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
<#
checklist
#>
# 服务Windows update是否禁用
$service_status = (Get-Service wuauserv).StartType;
if($service_status.ToString().CompareTo("Disabled") -eq 0){
    "1.Windows Update已禁用" | Out-File .\chek_result.log
}else{
    "1. Error: Windows Update未禁用，请尽快处理" | Out-File .\chek_result.log
};

# 磁盘清理
cleanmgr;
"2. 磁盘清理结束" | Out-File .\chek_result.log -NoClobber -Append;

# 补丁版本
"3. 镜像内自研软件补丁版本：" | Out-File .\chek_result.log -NoClobber -Append;
Dir hklm:\software\ecloudsoft\mirror\ |
ForEach-Object {
 $values = Get-ItemProperty $_.PSPath;
 "{0,-17}{1,-2}{2,-15}" -f $values.PSChildName, ":",$values.versioncode.ToString()
 } | Out-File .\chek_result.log -NoClobber -Append;

 # 公共文件夹遗漏
$items = Get-ChildItem C:\Users\Public\Desktop
if($items.Count -eq 0){
    "4. 公共桌面中没有遗漏图标" | Out-File .\chek_result.log -NoClobber -Append
}else{
    "4. Error: 公共桌面中遗漏图标如下，请尽快处理：" | Out-File .\chek_result.log -NoClobber -Append;
    $items | Out-File .\chek_result.log -NoClobber -Append
}

# kms激活情况
$kms_info = Get-WmiObject softwarelicensingservice;
$kms_status = $kms_info.RemainingWindowsReArmCount -eq 1001;
$kms_ip = $kms_info.KeyManagementServiceMachine;
"5.镜像内置kms地址未 $kms_ip , 激活情况是 $kms_status" | Out-File .\chek_result.log -NoClobber -Append;

# 文件夹Program file和Program File（x86）中是否有遗留文件
"6.文件夹Program file和Program File（x86）中是否有遗留文件" | Out-File .\chek_result.log -NoClobber -Append;
"**********************************镜像内已装软件如下：********************************************"| Out-File .\chek_result.log -NoClobber -Append;
(Get-WmiObject -Class Win32_Product).name | Out-File .\chek_result.log -NoClobber -Append;
"*******************************Program file中包含的文件如下**************************************"| Out-File .\chek_result.log -NoClobber -Append;
(Get-ChildItem "C:\Program Files").Name | Out-File .\chek_result.log -NoClobber -Append;
"****************************Program file (x86)中包含的文件如下**********************"| Out-File .\chek_result.log -NoClobber -Append;
(Get-ChildItem "C:\Program Files (x86)").Name | Out-File .\chek_result.log -NoClobber -Append;


"7.镜像内的开机启动项如下：" | Out-File .\chek_result.log -NoClobber -Append;
Get-ItemProperty -Path hkcu:\Software\Microsoft\Windows\CurrentVersion\Run | Out-File .\chek_result.log -NoClobber -Append;
Get-ItemProperty -Path hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | Out-File .\chek_result.log -NoClobber -Append;
Get-ItemProperty -Path hklm:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run | Out-File .\chek_result.log -NoClobber -Append;

# 静态IP
$net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Red Hat VirtIO Ethernet Adapter'"
$status = $net_wmi.DHCPEnabled
if ($status){
    "7. 网络IP状态为自动获取，不需要其他操作" | Out-File .\chek_result.log -NoClobber -Append;
}else{
    "7. Error：网络IP状态为静态，请设置为自动获取。" | Out-File .\chek_result.log -NoClobber -Append;
}

# cloudbase清理注册表
$cloudbase_regit = Dir "hklm:\software\cloudbase solutions\cloudbase-init" 
if($cloudbase_regit.count -eq 0){
    "8.cloudbase下注册表无残余项，不需要其他操作。" | Out-File .\chek_result.log -NoClobber -Append;
}else{
    "8.Error：cloudbase下注册表有残余项，请删除。" | Out-File .\chek_result.log -NoClobber -Append;
    $cloudbase_regit | Out-File .\chek_result.log -NoClobber -Append;
}
