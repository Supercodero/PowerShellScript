<#
用途：镜像封装前checklist
创建：2020/3/10
#>
# 显示Windows update服务状态
$service_status = (Get-Service wuauserv).StartType;
if($service_status.ToString().CompareTo("Disabled") -eq 0){
    "1.Windows Update服务已禁用" | Out-File .\chek_result.log
}else{
    "1. Error: Windows Update服务未禁用，请尽快处理." | Out-File .\chek_result.log
};

# 磁盘清理
#cleanmgr;
"2. 磁盘清理结束" | Out-File .\chek_result.log -NoClobber -Append;

# 查看各补丁版本
"3. 镜像内自研软件版本如下：" | Out-File .\chek_result.log -NoClobber -Append;
Dir hklm:\software\ecloudsoft\mirror\ |
ForEach-Object {
 $values = Get-ItemProperty $_.PSPath;
 "{0,-17}{1,-2}{2,-15}" -f $values.PSChildName, ":",$values.versioncode.ToString()
 } | Out-File .\chek_result.log -NoClobber -Append;

 # 公共桌面文件夹
$items = Get-ChildItem C:\Users\Public\Desktop
if($items.Count -eq 0){
    '4 公共文件夹中无残留文件' | Out-File .\chek_result.log -NoClobber -Append
}else{
    '4 公共文件夹中残留桌面图标如下，请尽快处理' | Out-File .\chek_result.log -NoClobber -Append;
    $items | Out-File .\chek_result.log -NoClobber -Append
}

# 查看虚机激活状态和内置kms地址
$kms_info = Get-WmiObject softwarelicensingservice;
$kms_status = $kms_info.RemainingWindowsReArmCount -eq 1001;
$kms_ip = $kms_info.KeyManagementServiceMachine;
"5.本机内置的kms地址为： $kms_ip , 激活状态为：$kms_status" | Out-File .\chek_result.log -NoClobber -Append;

# 检查program file和program file（x86）的文件夹
"6.请检查program file和program file（x86）的文件夹中是否遗留已卸载软件的文件" | Out-File .\chek_result.log -NoClobber -Append;
"**********镜像中的已装软件如下：************"| Out-File .\chek_result.log -NoClobber -Append;
(Get-WmiObject -Class Win32_Product).name | Out-File .\chek_result.log -NoClobber -Append;
"***********Program file文件夹中内容如下：**********"| Out-File .\chek_result.log -NoClobber -Append;
(Get-ChildItem "C:\Program Files").Name | Out-File .\chek_result.log -NoClobber -Append;
"*********Program file (x86)文件夹中内容如下：**********"| Out-File .\chek_result.log -NoClobber -Append;
(Get-ChildItem "C:\Program Files (x86)").Name | Out-File .\chek_result.log -NoClobber -Append;

# 