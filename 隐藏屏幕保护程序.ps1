

$ScreenSaver = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System'

New-Item -type Directory $ScreenSaver
#禁止屏保选项
New-ItemProperty $ScreenSaver -name "NoDispScrSavPage" -value "00000001" -propertyType dword