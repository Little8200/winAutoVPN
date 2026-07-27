Set WshShell = CreateObject("WScript.Shell") 
WshShell.Run chr(34) & "D:\autoVPN.bat" & Chr(34), 0, False

Set WshShell = Nothing