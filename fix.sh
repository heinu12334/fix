  if [ `id -u` != 0 ];then
    echo " (该功能仅限 root 用户执行)"
 else
 echo "开始修复..."
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    systemctl stop iptables
    systemctl disable iptables
    service stop iptables
    yum remove -y iptables
    yum remove -y firewalld
    iptables -F
    service stop iptables
    apt-get remove -y iptables
    ufw disable
  echo "修复完成"
  echo "如果代理还是无法链接请使用 lsof -i:端口号 命令查询端口是否被占用"
  fi
