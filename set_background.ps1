# 08  ”√

$path = "C:\Users\"+$env:UserName+"\AppData\Roaming\Microsoft\Windows\Themes\"
$wallpaperName = (Get-ChildItem $path | Sort-Object LastAccessTime -Descending | select -First 1).Name
$wallpapaerPath = $path+$wallpaperName

$setwallpapersrc = @"
using System.Runtime.InteropServices;
public class wallpaper
{
public const int SetDesktopWallpaper = 20;
public const int UpdateIniFile = 0x01;
public const int SendWinIniChange = 0x02;
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
public static void SetWallpaper ( string path )
{
SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
}
}
"@
Add-Type -TypeDefinition $setwallpapersrc
[wallpaper]::SetWallpaper($wallpapaerPath) 