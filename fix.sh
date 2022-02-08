  check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian|raspbian" /etc/issue; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /etc/issue; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian|raspbian" /proc/version; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /proc/version; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /proc/version; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ "${checkType}" == "sysRelease" ]]; then
        if [ "${value}" == "${release}" ]; then
            return 0
        else
            return 1
        fi
    elif [[ "${checkType}" == "packageManager" ]]; then
        if [ "${value}" == "${systemPackage}" ]; then
            return 0
        else
            return 1
        fi
    fi
}
  if [ `id -u` != 0 ];then
    echo " (该功能仅限 root 用户执行)"
 else
 echo "开始修复..."
  if check_sys packageManager yum; then
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    systemctl stop iptables
    systemctl disable iptables
    service stop iptables
    yum remove -y iptables
    yum remove -y firewalld
  elif check_sys packageManager apt; then
    iptables -F
    iptables -t nat -F
    iptables -P ACCEPT
    iptables -t nat -P ACCEPT
    service stop iptables
    apt-get remove -y iptables
    ufw disable
  fi
  
  if check_sys packageManager yum; then
    yum install -y epel-release
    yum update -y
	yum install -y iproute
  elif check_sys packageManager apt; then
    apt-get install -y epel-release
    apt-get update -y
	apt-get install -y iproute2
  fi
  echo "修复完成"
  echo "如果代理还是无法链接请使用 lsof -i:端口号 命令查询端口是否被占用"
  fi
