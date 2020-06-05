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
##L8/UAdDXTlGDjqXa8T9k9UrtR1QbYdKeq4WvwY2wzOn+sjXNdZ8MTGh0miz9FnSpS/MRULsQrNRx
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
#清理IE临时文件
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
#清理Internet Cookies
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2
#清理Internet历史记录
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1
#清理Internet密码
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 32

#清除系统日志
Clear-EventLog -Log Application, System, Security,"Windows PowerShell"   

#重置WindowsUpdate SID
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientIdValidation /f

#清理ｔｅｍｐ文件
Get-ChildItem $env:temp |   Remove-Item -Force -ErrorAction SilentlyContinue -Recurse 
Get-ChildItem C:\Windows\Temp,c:\temp |   Remove-Item -Force -ErrorAction SilentlyContinue -Recurse 

#重置ｄｎｓ
ipconfig /flushdns

#清空回收站
Clear-RecycleBin -Force

#清理最近浏览文件记录
Get-ChildItem $env:appdata\Microsoft\Windows\Recent | Remove-Item -Force -ErrorAction SilentlyContinue -Recurse 

#清理用户文件夹下文件
Get-ChildItem $env:USERPROFILE\Documents,$env:USERPROFILE\Downloads,$env:USERPROFILE\Pictures,$env:USERPROFILE\Music,$env:USERPROFILE\Videos,$env:USERPROFILE\Searches | Remove-Item -Force -ErrorAction SilentlyContinue -Recurse 

#清理云桌面下日志tool_log.txt
Remove-Item C:\tool_log.txt -Force -ErrorAction SilentlyContinue -Recurse 

#清理资源管理器地址栏记录
Remove-Item HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths -Force -ErrorAction SilentlyContinue -Recurse 
#清理资源管理器搜索记录
Remove-Item HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery -Force -ErrorAction SilentlyContinue -Recurse 
# 清理运行记录
Remove-Item HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU -Force -ErrorAction SilentlyContinue -Recurse 

# 清理cloudbase注册表项
Remove-Item "hklm:\software\cloudbase solutions\cloudbase-init"  -Force -ErrorAction SilentlyContinue -Recurse 
