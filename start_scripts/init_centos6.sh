#!/bin/bash
. /etc/init.d/functions
#----------------------------------------  环境检测   ----------------------------------------------
#判断执行脚本的用户是否是root用户，如果不是，则退出
if [[ "$(whoami)" != "root" ]]; then
    echo "please run this script as root ." >&2
    exit 1
fi
#警告
echo -e "\033[31m the script only Support CentOS_6 x86_64 \033[0m"
echo -e "\033[31m system initialization script, Please Seriously. press ctrl+C to cancel \033[0m"
# 按Y继续默认N，其他按键全部退出 #
yn="n"
echo "please input [Y\N]"
echo -n "default [N]: "
read yn
if [ "$yn" != "y" -a "$yn" != "Y" ]; then
echo "bye-bye!"
exit 0
fi
# 倒计时 #
for i in `seq -w 3 -1 1`
do
echo -ne "\b>>>>>$i";
sleep 1;
done
echo -e "\b\Good Luck"
# 检查是否为64位系统，这个脚本只支持64位脚本
platform=`uname -i`
if [ $platform != "x86_64" ];then
echo "this script is only for 64bit Operating System !"
exit 1
fi
echo "the platform is ok"
# 安装必要支持工具及软件工具
yum -y install redhat-lsb 
# clear
echo "Tools installation is complete"
# 检查系统版本为centos 6
distributor=`lsb_release -i | awk '{printupload $NF}'`
version=`lsb_release -r | awk '{print substr($NF,1,1)}'`
if [ $distributor != 'CentOS' -o $version != '6' ]; then
echo "this script is only for CentOS 6 !"
exit 1
fi
#env is ok
cat << EOF
+---------------------------------------+
|   your system is CentOS 6 x86_64      |
|           start optimizing            |
+---------------------------------------+
EOF
sleep 3
#----------------------------------------  开始优化   ----------------------------------------------
#配置网络
input_fun()
{
    OUTPUT_VAR=$1
    INPUT_VAR=""
    while [ -z $INPUT_VAR ];do
        read -p "$OUTPUT_VAR" INPUT_VAR
    done
    echo $INPUT_VAR
}
MYHOSTNAME=$(input_fun "please input the hostname:")
CARD_TYPE=$(input_fun "please input card type(eg:eth0):")
IPADDR=$(input_fun "please input ip address(eg:192.168.100.1):")
NETMASK=$(input_fun "please input netmask(eg:255.255.255.0):")
GATEWAY=$(input_fun "please input gateway(eg:192.168.100.1):")
MYDNS1=$(input_fun "please input DNS1(eg:114.114.114.114):")
MYDNS2=$(input_fun "please input DNS2(eg:8.8.4.4):")

MAC=$(ifconfig $CARD_TYPE | grep "HWaddr" | awk -F[" "]+ '{print $5}')

network_config(){
echo -e "\033[32;1m Start config network.. \033[0m"
cat >/etc/sysconfig/network <<ENDF
HOSTNAME=$MYHOSTNAME
ENDF

cat >/etc/sysconfig/network-scripts/ifcfg-$CARD_TYPE <<ENDF
DEVICE=$CARD_TYPE
BOOTPROTO=static
HWADDR=$MAC
NM_CONTROLLED=yes
ONBOOT=yes
TYPE=Ethernet
IPADDR=$IPADDR
NETMASK=$NETMASK
GATEWAY=$GATEWAY
DNS1=$MYDNS1
DNS2=$MYDNS2
ENDF

/etc/init.d/network restart

if [[ $? -ne 0 ]]; then
	action "network config Failed.." /bin/false
		exit 22
else
	action "Network config complete." /bin/true
#	echo -e "\033[32;1m network config complete,continue next one \033[0m"
fi
}

#配置yum源，并安装基本工具
yum_config(){
	echo -e "\033[32;1m Start config yum.. \033[0m"
    yum -y install wget
    cd /etc/yum.repos.d/
    mkdir bak
    mv ./*.repo bak
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
    yum clean all && yum makecache
    yum -y install vim unzip  openssl-client gcc gcc-c++ ntp ntpdate

	if [[ $? -ne 0 ]]; then
		action "yum config Failed.." /bin/false
			exit 22
	else
		action "yum config complete." /bin/true
	fi
}

#设置时间时区同步
time_config(){
	echo -e "\033[32;1m Start config time.. \033[0m"
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    # Update time
    /usr/sbin/ntpdate pool.ntp.org
    echo '*/5 * * * * /usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1' > /var/spool/cron/root;chmod 600 /var/spool/cron/root
    /sbin/service crond restart

	if [[ $? -ne 0 ]]; then
		action "Time config Failed.." /bin/false
			exit 22
	else
		action "time config complete." /bin/true
	fi
}

#设置语言
language_config(){
	echo -e "\033[32;1m Start config language.. \033[0m"
	export LANG=en_US.utf8
	if [[ -z `grep "LANG=en_US.utf8" /etc/rc.local` ]]; then
		echo "export LANG=en_US.utf8" >>/etc/rc.local
	fi
	
	if [[ $? -ne 0 ]]; then
		action "language config Failed.." /bin/false
			exit 22
	else
		action "language config complete." /bin/true
	fi
}


#修改文件打开数
fileopen_config(){
	echo -e "\033[32;1m Start config file open num.. \033[0m"
	echo "* soft nofile 66666" >> /etc/security/limits.conf
	echo "* hard nofile 66666" >> /etc/security/limits.conf

	if [[ $? -ne 0 ]]; then
		action "Fileopen config Failed.." /bin/false
			exit 22
	else
		action "Fileopen config complete." /bin/true
	fi
}

#增加用户并sudo提权
sudo_config(){
	echo -e "\033[32;1m Start config sudo.. \033[0m"
	USERNAME=$(input_fun "please input new user name:")
	useradd $USERNAME
	passwd $USERNAME
	
	chmod +w /etc/sudoers
	echo "$USERNAME        ALL=(ALL)     ALL" >>/etc/sudoers
	chmod -w /etc/sudoers

	if [[ $? -ne 0 ]]; then
		action "sudo config Failed.." /bin/false
			exit 22
	else
		action "sudo config complete." /bin/true
	fi
}


#关闭SEKINUX
selinux_config(){
	echo -e "\033[32;1m Start config selinux.. \033[0m"
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
	setenforce 0

	echo -e "\033[32;1m selinux is disabled,continue next one \033[0m"
}

#配置iptables
iptables_config(){
	echo -e "\033[32;1m Start config iptables.. \033[0m"
	iptables -F
	iptables -Z
	iptables -X
	
	iptables -A INPUT -p tcp  --dport 52113 -s 192.168.13.0/24  -j ACCEPT
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT
	
	iptables -P INPUT DROP
	iptables -P FORWARD DROP
	iptables -P OUTPUT ACCEPT
	
	iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	
	iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
	iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
	
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

	/etc/init.d/iptables save

	if [[ $? -ne 0 ]]; then
		action "iptables config Failed.." /bin/false
			exit 22
	else
		action "iptables config complete." /bin/true
	fi
}

#配置SSHD
sshd_config(){
	echo -e "\033[32;1m Start config sshd.. \033[0m"
	sed -i 's/#Port 22/Port 52113/g' /etc/ssh/sshd_config
	sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
	sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
	/etc/init.d/sshd restart

	if [[ $? -ne 0 ]]; then
		action "ssh config Failed.." /bin/false
			exit 22
	else
		action "sshd config complete." /bin/true
	fi
}

#内核参数优化


#main
main(){
	network_config
	yum_config
	time_config
	language_config
	fileopen_config
	sudo_config
	selinux_config
	iptables_config
	sshd_config
}
main
