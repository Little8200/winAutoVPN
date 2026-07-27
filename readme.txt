【使用说明】：
1、文件夹中三个文件需提取出来，单独放在D盘根目录下
autoVPN.bat
autoVPN.vbs
runMe.ps1

2、用记事本打开autoVPN.bat文件，修改对应内容（确保信息填写准确可用）：
set "VPN_NAME=这里VPN账号"
set "VPN_PWD=这里写VPN密码"
set "VPN_SERVER=这里写VPN的公网IP地址"
set "VPN_PSK=这些里共享密钥"

3、将D盘根目录下的：
runMe.ps1，鼠标右键以PowerShell运行即可
双击autoVPN.vbs文件即可

【功能说明】
支持以下：
1、vpn开机强制自动连接（首次可能需要输入账号密码保存）
2、30秒检测断开vpn，自动触发重新连接