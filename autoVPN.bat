@echo off
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    powershell -Command "Start-Process '%~nx0' -Verb RunAs"
    exit /b
)
chcp 936 > nul
title Win10自动化配置VPN
setlocal enabledelayedexpansion
set "VPN_NAME=这里VPN账号"
set "VPN_PWD=这里写VPN密码"
set "VPN_SERVER=这里写VPN的公网IP地址"
set "VPN_PSK=这些里共享密钥"

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "LOG_FILE=D:\vpn_%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%.log"

forfiles /p "D:\" /m vpn_*.log /d -30 /c "cmd /c del @path" >nul 2>&1


reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\Parameters /v AllowL2TPWeakCrypto /t REG_DWORD /d 1 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\Parameters /v AllowPPTPWeakCrypto /t REG_DWORD /d 1 /f

powershell -Command "$c=Get-VpnConnection -Name '%VPN_NAME%' -ErrorAction SilentlyContinue; if(!$c){exit 1}"

if !errorlevel! equ 1 (
  echo [1/3] 正在清理旧配置... >> "%LOG_FILE%"
  powershell -Command "Remove-VpnConnection -Name '%VPN_NAME%' -Force -ErrorAction SilentlyContinue" >nul 2>&1
  echo [2/3] 正在创建新的 VPN 连接... >> "%LOG_FILE%"
  powershell -Command "Add-VpnConnection -Name '%VPN_NAME%' -ServerAddress '%VPN_SERVER%' -TunnelType L2tp -EncryptionLevel Required -AuthenticationMethod Pap,Chap,MSChapv2 -L2tpPsk '%VPN_PSK%' -Force"
  if !errorlevel! neq 0 (
    echo ? 配置失败！ >> "%LOG_FILE%"
    exit /b 1
  )
  echo [3/3] 配置完成！>> "%LOG_FILE%"
) else (
    echo VPN 配置已存在，跳过创建步骤。 >> "%LOG_FILE%"
)
set FAIL_COUNT=0

:LOOP

rasdial | findstr /C:"%VPN_NAME%" >nul

if !errorlevel! equ 0 (
    echo [%time%] 网络正常，VPN 已连接。>> "%LOG_FILE%"
) else (
    echo [%time%] 检测到断开，正在尝试重连... >> "%LOG_FILE%"
    rasdial "%VPN_NAME%" "%VPN_NAME%" "%VPN_PWD%" >> "%LOG_FILE%" 2>&1
    if !errorlevel! equ 0 (
        echo [%time%] 重连成功！ >> "%LOG_FILE%"
       set FAIL_COUNT=0
    ) else (
        set /a FAIL_COUNT+=1
        echo [%time%] 重连失败，将在60秒后重试... >> "%LOG_FILE%"
        if !FAIL_COUNT! geq 5 (
            timeout /t 600 >nul
            set FAIL_COUNT=0
        )
    )
)
timeout /t 300 >nul
goto LOOP
