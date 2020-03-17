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
$key="ip"
$val="192.168.0.1"
$retVal=New-Object System.Text.StringBuilder(32)
$net_wmi = Get-WmiObject win32_networkadapterconfiguration -filter "Description = 'Intel(R) Dual Band Wireless-AC 8265'"
 
#生成或修改配置文件
$null=$ini::WritePrivateProfileString($section,$key,$val,$filePath)
$null=$ini::WritePrivateProfileString($section,"submask",0,$filePath)
$null=$ini::WritePrivateProfileString($section,"gateway",$net_wmi.DefaultIPGateway[0],$filePath)
$null=$ini::WritePrivateProfileString($section,"subnet_mask",$net_wmi.IPSubnet[0],$filePath)
$null=$ini::WritePrivateProfileString($section,"dnsarr",$net_wmi.DNSServerSearchOrder,$filePath)
$script_status = "0"
$null=$ini::WritePrivateProfileString($section,"script_status",$script_status,$filePath)

 
#查看配置文件
$null=$ini::GetPrivateProfileString($section,"1","",$retVal,32,$filePath)
$retVal.ToString().CompareTo("0")
