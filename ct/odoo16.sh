#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

   ____        _                     __     __  
  / __ \      | |                   /_ |   / /  
 | |  | |   __| |   ___     ___      | |  / /_  
 | |  | |  / _` |  / _ \   / _ \     | | | '_ \ 
 | |__| | | (_| | | (_) | | (_) |    | | | (_) |
  \____/   \__,_|  \___/   \___/     |_|  \___/ 
                                                
                                                
EOF
}
header_info
echo -e "Loading..."
APP="Odoo 16"
var_disk="4"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
  header_info
  if [[ ! -d /opt/odoo ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
    read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
    [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
  fi
  wget -qL https://github.com/odoo/odoo/archive/refs/heads/16.0.zip
  msg_info "Stopping Odoo 16"
  systemctl stop odoo16
  msg_ok "Stopped odoo16"

  msg_info "Updating Odoo16"
  unzip 16.0.zip -d /opt/odoo
  msg_ok "Updated AdguardHome"

  msg_info "Starting Odoo 16"
  systemctl start odoo16
  msg_ok "Started Odoo 16"

  msg_info "Cleaning Up"
  rm -rf 16.0.zip
  msg_ok "Cleaned"
  msg_ok "Updated Successfully"
  exit
}

function exit-script() {
  clear
  echo -e "⚠  User exited script \n"
  exit
}

funtion advanced_settings() {
  if ADMINPW=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Odoo Admin Password" 8 58 --title "ADMIN PASSWORD" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    echo -e "${DGN}Chosen password: ${BGN}$ADMINPW${CL}"
  else
    exit-script
  fi

  if DBIP=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Database IP Address" 8 58 localhost --title "DB IP" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    echo -e "${DGN}DataBase IP Address: ${BGN}$DBIP${CL}"
  else
    exit-script
  fi

  if DBPORT=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "DataBase Port" 8 58 5432 --title "DB PORT" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    echo -e "${DGN}Chosen port: ${BGN}$DBPORT${CL}"
  else
    exit-script
  fi

  if DBUSER=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "DataBase User" 8 58 --title "DB USER" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    echo -e "${DGN}Chosen DB user: ${BGN}$DBUSERNPW${CL}"
  else
    exit-script
  fi

  if DBPW=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "DataBase password" 8 58 --title "DB PASSWORD" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    echo -e "${DGN}Chosen DB password: ${BGN}$DBPW${CL}"
  else
    exit-script
  fi

  if DBNAME=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "DataBase Name" 8 58 --title "DB NAME" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    echo -e "${DGN}Chosen DB name: ${BGN}$DBNAME${CL}"
  else
    exit-script
  fi

}
start
build_container
description

msg_info "Initializing Odoo Database"

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:8069${CL} \n"
