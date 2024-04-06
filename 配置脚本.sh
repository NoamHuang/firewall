#********************************** client虚拟机上执行如下ssh配置命令  **********************************

#
sudo ifconfig enp0s3 192.168.0.10/24 netmask 255.255.255.0 up && sudo route add default gw 192.168.0.100 && route -n

sudo vim /etc/netplan/01-netcfg.yaml
# 01-netcfg.yaml 配置开始
network:
	version: 2
	renderer: networkd
	ethernets:
		enp0s3:
			dhcp4: no
			addresses:
				- 192.168.0.10/24
			gateway4: 192.168.0.100
			nameservers:
				addresses: [8.8.8.8,8.8.4.4]
# 01-netcfg.yaml 配置结束

sudo netplan apply

# 调试命令 sudo netplan -d apply



#********************************** server虚拟机上执行如下ssh配置命令  **********************************

#
sudo ifconfig enp0s3 10.0.0.10 netmask 255.0.0.0 up && sudo route add default gw 10.0.0.100 && route -n


sudo vim /etc/netplan/01-netcfg.yaml
# 01-netcfg.yaml 配置开始
network:
	version: 2
	renderer: networkd
	ethernets:
		enp0s3:
			dhcp4: no
			addresses:
				- 10.0.0.10/8
			gateway4: 10.0.0.100
			nameservers:
				addresses: [8.8.8.8,8.8.4.4]
# 01-netcfg.yaml 配置结束

sudo netplan apply


#********************************** gateway虚拟机上执行如下ssh配置命令  **********************************
#用于连接Client虚拟机网卡
sudo ifconfig enp0s3 192.168.0.100 netmask 255.255.255.0 up

#用于连接Server虚拟机网卡
sudo ifconfig enp0s8 10.0.0.100 netmask 255.0.0.0 up

#gateway虚拟机网卡，用于动态IP
sudo dhclient enp0s9

# 命令集合
sudo ifconfig enp0s3 192.168.0.100 netmask 255.255.255.0 up && sudo ifconfig enp0s8 10.0.0.100 netmask 255.0.0.0 up && sudo dhclient enp0s9 && route -n


sudo vim /etc/netplan/01-netcfg.yaml

# 01-netcfg.yaml 配置开始
network:
	version: 2
	renderer: networkd
	ethernets:
		enp0s3:
			dhcp4: no
			addresses:
				- 192.168.0.100/24
			nameservers:
				addresses: [8.8.8.8,8.8.4.4]
		enp0s9:
			dhcp4: yes
			nameservers:
				addresses: [8.8.8.8,8.8.4.4]
		enp0s8:
			dhcp4: no
			addresses:
				- 10.0.0.100/8
			nameservers:
				addresses: [8.8.8.8,8.8.4.4]
# 01-netcfg.yaml 配置结束


sudo netplan apply

sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE

sudo vim /etc/sysctl.conf
# 在打开的文件尾部追加配置
net.ipv4.ip_forward=1

sudo sysctl -p







