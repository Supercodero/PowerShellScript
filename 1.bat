taskkill /f /im explorer.exe

attrib -h -i %userprofile%\AppData\Local\IconCache.db

del %userprofile%\AppData\Local\IconCache.db /a

start explorer
