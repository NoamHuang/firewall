#!/bin/sh

####
# 1.1. Internet ip address
# 
#
Internet_IP="172.16.0.4"
Internet_IP_RANGE="172.16.0.0/12"
Internet_BCAST_ADRESS="172.31.255.255"
Internet_IFACE="enp0s9"

####
# 1.2 Client network configuration.
#
#

#
# IP addresses of the client-side network
#
Client_NET_IP="192.168.0.10"
Client_NET_IP_RANGE="192.168.0.0/24"
Client_NET_BCAST_ADRESS="192.168.0.255"
Client_NET_IFACE="enp0s3"

####
# 1.3 Server Network Configuration.
#

#
# IP addresses of the server-side network
#
Server_NET_IP="10.0.0.10"
Server_NET_IP_RANGE="10.0.0.0/8"
Server_NET_BCAST_ADRESS="10.255.255.255"
Server_NET_IFACE="enp0s8"

#
# IP aliases for the server (server's IP address)
#
LO_IFACE="lo"
LO_IP="127.0.0.1"
WEB_IP_ADDRESS="10.0.0.10"
MAIL_IP_ADDRESS="10.0.0.10"
SSH_IP_ADDRESS="10.0.0.10"
DNS_IP_ADDRESS="10.0.0.10"
FTP_IP_ADDRESS="10.0.0.10"
#IP aliases for NATed services (this is the GW's ip on client network)
NAT_WEB_IP_ADDRESS="192.168.0.100"
NAT_MAIL_IP_ADDRESS="192.168.0.100"
NAT_SSH_IP_ADDRESS="192.168.0.100"
NAT_DNS_IP_ADDRESS="192.168.0.100"
NAT_FTP_IP_ADDRESS="192.168.0.100"
PASV_FTP_PORT_RANGE="30000:30099"

####
# 1.4 IPTables Configuration.
#

IPTABLES="/sbin/iptables"


#######################################################
#                                                     #
# 2. Module loading.                                  #
#                                                     #
#######################################################
#
# Needed to initially load modules
#
/sbin/depmod -a	 

#
# flush iptables
#
$IPTABLES -F 
$IPTABLES -X 
$IPTABLES -F -t nat

#####
# 2.1 Required modules
#

/sbin/modprobe ip_tables
/sbin/modprobe ip_conntrack
/sbin/modprobe iptable_filter
/sbin/modprobe iptable_mangle
/sbin/modprobe iptable_nat
/sbin/modprobe ipt_LOG
/sbin/modprobe ipt_limit
/sbin/modprobe ipt_state

#####
# 2.2 Non-frequently used modules
#

#/sbin/modprobe ipt_owner
#/sbin/modprobe ipt_REJECT
#/sbin/modprobe ipt_MASQUERADE
#/sbin/modprobe ip_conntrack_ftp
#/sbin/modprobe ip_conntrack_irc
#/sbin/modprobe ip_nat_ftp

###########################################################################
#
# 3. /proc set up.
#

#
# 3.1 Required proc configuration
#

#
# Enable ip_forward, this is critical since it is turned off as defaul in 
# Linux.
#
echo "1" > /proc/sys/net/ipv4/ip_forward

#
# 3.2 Non-Required proc configuration
#

#
# Dynamic IP users:
#
#echo "1" > /proc/sys/net/ipv4/ip_dynaddr

###########################################################################
#
# 4. rules set up.
#

# The kernel starts with three lists of rules; these lists are called firewall
# chains or just chains. The three chains are called INPUT, OUTPUT and FORWARD.
#
# The chains are arranged like so:
#
#                     _____
#                    /     \
#  -->[Routing ]--->|FORWARD|------->
#     [Decision]     \_____/        ^
#          |                        |
#          v                       ____
#         ___                     /    \
#        /   \                   |OUTPUT|
#       |INPUT|                   \____/
#        \___/                      ^
#          |                        |
#           ----> Local Process ----
#
# 1. When a packet comes in (say, through the Ethernet card) the kernel first 
#    looks at the destination of the packet: this is called `routing'.
# 2. If it's destined for this box, the packet passes downwards in the diagram, 
#    to the INPUT chain. If it passes this, any processes waiting for that 
#    packet will receive it. 
# 3. Otherwise, if the kernel does not have forwarding enabled, or it doesn't 
#    know how to forward the packet, the packet is dropped. If forwarding is 
#    enabled, and the packet is destined for another network interface (if you 
#    have another one), then the packet goes rightwards on our diagram to the 
#    FORWARD chain. If it is ACCEPTed, it will be sent out. 
# 4. Finally, a program running on the box can send network packets. These 
#    packets pass through the OUTPUT chain immediately: if it says ACCEPT, then 
#    the packet continues out to whatever interface it is destined for. 
#


#####
# 4.1 Filter table
#

#
# 4.1.1 Set policies
#

#
# Set default policies for the INPUT, FORWARD and OUTPUT chains
#

# Whitelist (Whitelist is preferred)
#$IPTABLES -P INPUT DROP
#$IPTABLES -P OUTPUT DROP
#$IPTABLES -P FORWARD DROP

# Blacklist
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT

#
# 4.1.2 Create user-specified chains
#

#
# Example of creating a chain for bad tcp packets
#

#$IPTABLES -N bad_tcp_packets

#
# Create separate chains for allowed (whitelist), ICMP, TCP and UDP to traverse
#

#$IPTABLES -N allowed
#$IPTABLES -N tcp_packets
#$IPTABLES -N udp_packets
#$IPTABLES -N icmp_packets

#
# In the following 4.1.x, you can provide individual user-specified rules


#
# 4.1.3 Example of create content in user-specified chains (bad_tcp_packets)
#

#
# bad_tcp_packets chain
#

#$IPTABLES -A bad_tcp_packets -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j REJECT --reject-with tcp-reset 
#$IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG --log-prefix "New not syn:"
#$IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP

#
# 4.1.4 Example of allowed chain (allow packets for initial TCP or already established TCP sessions)
#

#$IPTABLES -A allowed -p TCP --syn -j ACCEPT
#$IPTABLES -A allowed -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
#$IPTABLES -A allowed -p TCP -j DROP


#####
# 4.2 FORWARD chain
#

#
# Provide your forwarding rules below
#

# example of checking bad tcp packets
#$IPTABLES -A FORWARD -p tcp -j bad_tcp_packets

# Allow http traffic from client network to server network
#$IPTABLES -A FORWARD -p TCP --dport 80 -i $Client_NET_IFACE -s $Client_NET_IP_RANGE -d $WEB_IP_ADDRESS -j ACCEPT
#$IPTABLES -A FORWARD -p TCP --sport 80 -i $Server_NET_IFACE -s $WEB_IP_ADDRESS -d $Client_NET_IP_RANGE -j ACCEPT

# example of using allowed
#$IPTABLES -A FORWARD -p tcp -j allowed


#####
# 4.3 INPUT chain
#

#
# Provide your input rules below
#

#
# Example of checking bad TCP packets we don't want.
#

#$IPTABLES -A INPUT -p tcp -j bad_tcp_packets

#####
# 4.3 OUTPUT chain
#

#
# Provide your output rules below
#

#
# Example of checking bad TCP packets we don't want.
#

#$IPTABLES -A OUTPUT -p tcp -j bad_tcp_packets

#####################################################################
#                                                                   #
# 5. NAT setup                                                      #
#                                                                   #
#####################################################################

#####
# 5.1  PREROUTING chain.
#
#
# Provide your NAT PREROUTING rules (packets come into your private domain)
#

#
# Example of enable http to internal web server behind the firewall (port forwarding)
#

# web
#$IPTABLES -t nat -A PREROUTING -p tcp -d $NAT_WEB_IP_ADDRESS --dport 80 -j DNAT --to $WEB_IP_ADDRESS



#####
# 5.2 POSTROUTING chain.
#
#
# Provide your NAT PREROUTING rules (packets go to the public domain)
#

# Allow client and server network nodes to access to Internet using masquerade
$IPTABLES -t nat -A POSTROUTING -o $Internet_IFACE -j MASQUERADE

# Allow the web server reply to the client go through the NAT 
#$IPTABLES -t nat -A POSTROUTING -p tcp -s $WEB_IP_ADDRESS -o $Client_NET_IFACE --sport 80 -j SNAT --to $Client_NET_IP


