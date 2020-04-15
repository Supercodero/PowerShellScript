##[Ps1 To Exe]
##
##NcDBCIWOCzWE8paP3yN490D9Umkoa/mrtqGi1rK0+ubgiCbLQIoAdXBlnz/5Fne+V/4QBdZbt9AFNQ==
##NcDBCIWOCzWE8paP3yN490D9Umkoa/mrtqGi1rK0+ubgiCbLQIoAdXBlnz/5Fneed94wBdY04oVffDMMTw==
##NcDBCIWOCzWE8paP3yN490D9Umkoa/mrtqGi1rK0+ubgiCbLQIoAdXBlnz/5FnePXPMWWPBbvMUQNQ==
##NcDBCIWOCzWE8paP3yN490D9Umkoa/mrtqGi1rK0+ubgiCbLQIoAdXBlnz/5FneoX+AbXLsWtdNx
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
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdZsQTWtnhCDyEE6vF/cKUJU=
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
$PrinterDriverPath=".\CNLB0CA64.INF"
$PrinterDriverName="Canon iR-ADV C3320L UFR II"
$PrinterPortName="IP_10.190.191.251"
$PrinterPort="10.190.191.251"
$PrinterName="广报19楼打印机"
$Run_Status="False"


Start-Process C:\Windows\System32\pnputil.exe -a $PrinterDriverPath


$checkPrinterExists =Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
if(-not $checkPrinterExists){
# 添加驱动到驱动组中
pnputil.exe -i -a $PrinterDriverPath
Add-PrinterDriver -Name $PrinterDriverName
}else{
$ws = New-Object -ComObject WScript.Shell  
$wsr = $ws.popup("打印机已存在，安装取消",0,"提示",0 + 16)
exit
}


$checkPortExists = Get-Printerport -Name $PrinterPortName -ErrorAction SilentlyContinue
if (-not $checkPortExists) {
Add-PrinterPort -name $PrinterPortName -PrinterHostAddress $PrinterPort
}


Add-Printer -Name $PrinterName -DriverName $PrinterDriverName -PortName $PrinterPortName -Published -ErrorAction SilentlyContinue


(Get-WmiObject -ComputerName . -Class Win32_Printer -Filter "Name='$PrinterName'").SetDefaultPrinter()
(New-Object -ComObject WScript.Network).SetDefaultPrinter($PrinterName)
$Run_Status=$?


if($Run_Status -eq "True"){
$ws = New-Object -ComObject WScript.Shell  
$wsr = $ws.popup("打印机安装完毕，稍后可在控制面板中查看",0,"提示",0 + 64)
Remove-Item -Path ".\cnlb0C.cat",".\Readme.hta",".\ufrii.cab",".\CNLB0CA64.INF"
exit
}
else{
$ws = New-Object -ComObject WScript.Shell  
$wsr = $ws.popup("安装错误，请联系系统管理员",0,"提示",0 + 16)
Remove-Item -Path ".\cnlb0C.cat",".\Readme.hta",".\ufrii.cab",".\CNLB0CA64.INF"
exit
}