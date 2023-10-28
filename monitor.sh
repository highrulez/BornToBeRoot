#!/bin/bash

# System information
architecture=$(uname -a)
physical_cpu_count=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
virtual_cpu_count=$(grep "^processor" /proc/cpuinfo | wc -l)

# Memory information
total_memory=$(free -m | awk '$1 == "Mem:" {print $2}')
used_memory=$(free -m | awk '$1 == "Mem:" {print $3}')
memory_usage_percentage=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk information
total_disk_space_GB=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
used_disk_space_MB=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
disk_usage_percentage=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d"), ut/ft*100}')

# CPU load
cpu_load=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')

# System uptime
last_boot_time=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# LVM usage
lvm_count=$(lsblk | grep "lvm" | wc -l)
lvm_usage_status=$(if [ $lvm_count -eq 0 ]; then echo no; else echo yes; fi)

# Network information
tcp_connections=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
logged_in_users=$(users | wc -w)
ip_address=$(hostname -I)
mac_address=$(ip link show | awk '$1 == "link/ether" {print $2}')

# Sudo commands count
sudo_commands_count=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# Display system information
wall "System Information:
- Architecture: $architecture
- Physical CPUs: $physical_cpu_count
- Virtual CPUs: $virtual_cpu_count
- Memory Usage: $used_memory/${total_memory}MB ($memory_usage_percentage%)
- Disk Usage: $used_disk_space_MB/${total_disk_space_GB}GB ($disk_usage_percentage%)
- CPU Load: $cpu_load
- Last Boot: $last_boot_time
- LVM Use: $lvm_usage_status
- TCP Connections: $ctcp ESTABLISHED
- Logged-in Users: $logged_in_users
- Network: IP $ip_address ($mac_address)
- Sudo Commands Executed: $sudo_commands_count cmd"
