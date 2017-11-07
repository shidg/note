# XX-Net开启ipv6。以获取更多可用ip。前提需要操作系统开启ipv6支持
# windows 7 配置ISATAP隧道支持(Teredo)以支持ipv6


开始——运行——输入"gpedit.msc"
依次打开：计算机配置——管理模板——网络——TCPIP设置——IPv6转换技术，如有已配置或禁用、启用等均修改为"未配置"


开始——控制面板——查看方式“大图标”——windows防火墙——还原默认设置 


设置IPV6 DNS
2001:4860:4860::8888
2001:4860:4860::8844

管理员身份运行ipv6_1.bat
管理员身份运行ipv6_2.bat


重新启动系统


http://test-ipv6.com测试ipv6可用性


XX-Net开启ipv6支持
