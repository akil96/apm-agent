#!/bin/bash

set -x
set -e

AGENTDIR="/opt/sfagent"
TDAGENTCONFDIR="/etc/td-agent-bit"
ID=`cat /etc/os-release | grep -w "ID" | cut -d"=" -f2 | tr -d '"'`
SERVICEFILE="/etc/systemd/system/sfagent.service"

uninstall_jcmd()
{

if [ "$ID" = "debian" ] || [ "$ID" = "ubuntu" ]; then
apt-get purge --auto-remove -y openjdk-9-jdk-headless
fi

if [ "$ID" = "centos" ]; then
yum remove -y java-1.8.0-openjdk-devel
fi

}

uninstall_fluent_bit()
{

if [ "$ID" = "debian" ] || [ "$ID" = "ubuntu" ]; then
systemctl stop td-agent-bit
systemctl disable td-agent-bit
apt-get purge --auto-remove -y mmdb-bin
apt-get purge --auto-remove -y td-agent-bit
fi

if [ "$ID" = "centos" ]; then
systemctl stop td-agent-bit
systemctl disable td-agent-bit

yum remove -y td-agent-bit
rm -rf $TDAGENTCONFDIR
rm /etc/yum.repos.d/td-agent-bit.repo
fi

rm -f /etc/logrotate.d/td-agent-bit

}

uninstall_apm_agent()
{
if [ -f "$SERVICEFILE" ];
then
    echo "remove sfagent service"
    systemctl stop sfagent
    systemctl disable sfagent
    rm -f /etc/systemd/system/sfagent.service
    systemctl daemon-reload
fi
rm -rf  $AGENTDIR
rm -rf /var/log/sfagent

}

uninstall_services()
{

uninstall_apm_agent
uninstall_fluent_bit
#uninstall_jcmd

}

oldpath=`pwd`
cd /tmp
uninstall_services
cd $oldpath

