#!/bin/bash

clear

echo 'checking SELinux status...'

sestatus

setenforce 0

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

echo 'SELinux turned off!'

echo 'configure DNF or YUM'

echo 'installing epel-release...'
dnf install epel-release -y

echo 'installing softwares...'
dnf install vim screen git wget curl net-tools gcc-c++ make python-devel NetworkManager-tui -y

echo 'installing extra softwares...'
dnf install yum-utils device-mapper-persistent-data lvm2 htop telnet -y

echo 'installing nodejs related...'
curl -fsSL https://rpm.nodesource.com/setup_21.x | bash -
dnf install -y nodejs

curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
dnf install -y yarn

echo 'configuring modern unix softwares...'

# go to tmp dir.
cd /tmp
# Download latest version.
curl -sfL https://git.io/getgot | /bin/bash
# Make the binary executable.
chmod +x /tmp/bin/got
# Move the binary to your PATH
mv /tmp/bin/got /usr/bin/got

yarn global add gtop

dnf install ripgrep -y
dnf copr enable atim/bottom -y
dnf install bottom -y

dnf copr enable atim/gping -y
dnf install gping -y

dnf install pip -y
pip install --user 'glances[action,cloud,cpuinfo,docker,export,folders,gpu,graph,ip,raid,snmp,wifi]'

cd /tmp && curl -L https://github.com/bootandy/dust/releases/download/v0.8.4/dust-v0.8.4-x86_64-unknown-linux-gnu.tar.gz -o dust.tar.gz
tar -xvf dust.tar.gz
chmod +x /tmp/dust-v0.8.4-x86_64-unknown-linux-gnu/dust
mv /tmp/dust-v0.8.4-x86_64-unknown-linux-gnu/dust /usr/bin/dust

dnf install https://github.com/dalance/procs/releases/download/v0.14.0/procs-0.14.0-1.x86_64.rpm -y

cd /tmp && curl -L https://github.com/rs/curlie/releases/download/v1.6.9/curlie_1.6.9_linux_amd64.rpm -o curlie_1.6.9_linux_amd64.rpm
dnf install /tmp/curlie_1.6.9_linux_amd64.rpm -y

cd /tmp && curl -L https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_amd64.rpm -o duf_0.8.1_linux_amd64.rpm
dnf install /tmp/duf_0.8.1_linux_amd64.rpm -y

cd /tmp && curl -L https://github.com/sharkdp/fd/releases/download/v8.6.0/fd-v8.6.0-x86_64-unknown-linux-gnu.tar.gz -o fd.tar.gz
tar -xvf /tmp/fd.tar.gz
chmod +x /tmp/fd-v8.6.0-x86_64-unknown-linux-gnu/fd
mv /tmp/fd-v8.6.0-x86_64-unknown-linux-gnu/fd /usr/bin/fd

echo 'alias top=glances' | tee -a /etc/profile.d/modern_linux.sh
echo 'alias htop=btm' | tee -a /etc/profile.d/modern_linux.sh
echo 'alias ps=procs' | tee -a /etc/profile.d/modern_linux.sh
echo 'alias du=dust' | tee -a /etc/profile.d/modern_linux.sh
echo 'alias df=duf' | tee -a /etc/profile.d/modern_linux.sh
echo 'alias find=fd' | tee -a /etc/profile.d/modern_linux.sh
echo 'alias grep=rg' | tee -a /etc/profile.d/modern_linux.sh
echo 'alias curl=curlie' | tee -a /etc/profile.d/modern_linux.sh
source /etc/profile.d/modern_linux.sh

echo 'configuring ssh...'
echo 'PermitEmptyPasswords no' | tee -a /etc/ssh/sshd_config
echo 'UseDNS no' | tee -a /etc/ssh/sshd_config
echo 'GSSAPIAuthentication no' | tee -a /etc/ssh/sshd_config
echo 'PermitRootLogin prohibit-password' | tee -a /etc/ssh/sshd_config
echo 'RSAAuthentication yes' | tee -a /etc/ssh/sshd_config
echo 'PubkeyAuthentication yes' | tee -a /etc/ssh/sshd_config

echo 'configuring system limits...'
echo '* soft nofile 65536' | tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | tee -a /etc/security/limits.conf
echo '* soft nproc 65536' | tee -a /etc/security/limits.conf
echo '* hard nproc 65536' | tee -a /etc/security/limits.conf

echo 'configuring system paramaters...'
echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf
echo 'net.core.netdev_max_backlog=41960' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_max_tw_buckets=300000' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.disable_ipv6=1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6=1' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_fastopen=3' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog=16384' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout=30' | tee -a /etc/sysctl.conf
echo 'net.core.somaxconn=10240' | tee -a /etc/sysctl.conf
echo 'net.core.default_qdisc=fq' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_mem=786432 4194304 8388608' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem=16384 16384 4206592' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem=16384 16384 4206592' |  tee -a /etc/sysctl.conf
echo 'net.core.rmem_default=262144' |  tee -a /etc/sysctl.conf
echo 'net.core.wmem_default=262144' |  tee -a /etc/sysctl.conf
echo 'net.core.rmem_max=16777216' |  tee -a /etc/sysctl.conf
echo 'net.core.wmem_max=16777216' |  tee -a /etc/sysctl.conf
echo 'vm.overcommit_memory=1' |  tee -a /etc/sysctl.conf
sysctl -p

echo 'performing full system update...'
dnf update -y

echo 'clean up...'
rm -rf /tmp/*

echo '===== ALL DONE, SYSTEM INITIALIZED! ====='
echo 'other: systemctl stop firewalld && systemctl disable firewalld'

