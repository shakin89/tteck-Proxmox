#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y libyaml-dev
$STD apt-get install -y build-essential
$STD apt-get install -y wget
$STD apt-get install -y libfreetype6-dev
$STD apt-get install -y libxml2-dev
$STD apt-get install -y libzip-dev
$STD apt-get install -y libsasl2-dev
$STD apt-get install -y node-less
$STD apt-get install -y libjpeg-dev
$STD apt-get install -y zlib1g-dev
$STD apt-get install -y libpq-dev
$STD apt-get install -y libxslt1-dev
$STD apt-get install -y libldap2-dev
$STD apt-get install -y libtiff5-dev
$STD apt-get install -y libopenjp2-7-dev
$STD apt-get install -y wkhtmltopdf
$STD apt-get install -y acl
$STD apt-get install -y unzip
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  python3-wheel \
  python3-setuptools \
  python3-psycopg2
$STD apt-get install -y virtualenv
msg_ok "Updated Python3"

msg_info "Creating user odoo"
useradd -m -s /bin/bash -p $(openssl passwd -1 odoo) odoo
usermod -aG sudo,tty,dialout odoo
chown -R odoo:odoo /opt
msg_ok "Created user odoo"

msg_info "Installing Odoo 16"
$STD sudo -u odoo bash << EOF
mkdir /opt/odoo
cd /opt/odoo
python3 -m venv .
source bin/activate
pip install --upgrade pip
wget -qL https://github.com/odoo/odoo/archive/refs/heads/16.0.zip
unzip -qq 16.0.zip -d /opt/odoo
rm -rf 16.0.zip
mkdir -p /opt/odoo/odoo-16.0/custom-addons
cd /opt/odoo/odoo-16.0
pip install -r requirements.txt
EOF
msg_ok "Installed odoo"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/odoo.service
[Unit]
Description=Odoo 16
After=network.target 
Wants=network-online.target

[Service]
Type=simple
SyslogIdentifier="odoo16"
PermissionsStartOnly=true
User=odoo
Group=odoo
ExecStart=/opt/odoo/bin/python3 /opt/odoo/odoo-16.0/odoo-bin -c /etc/odoo16.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now odoo16.service
msg_ok "Created Service"

msg_info "Creating Configuration file"
cat <<EOF >/etc/odoo16.conf
[options]
admin_passwd = "$ADMINPW"
db_host = $DBIP
db_port = $DBPORT
db_user = $DBUSER
db_password = $DBPW
db_name = $DBNAME
db_sslmode = prefer
addons_path = /opt/odoo/odoo-16.0/addons,/opt/odoo/odoo-16.0/custom-addons
xmlrpc_port = 8069
default_productivity_apps = True
EOF
msg_ok "Created Configuration file"


motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
