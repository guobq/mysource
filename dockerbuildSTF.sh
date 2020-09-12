#!/bin/bash
 
#IP
IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print$2}' | awk -F "/" '{print $1}'`
echo $IP
 
#docker安装-安装软件包
yum install -y yum-utils device-mapper-persistent-data lvm2
 
#docker安装-设置稳定的仓库
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
 
#docker安装---列出并排序存储库中可用的docker版本
yum list docker-ce --showduplicates | sort -r
 
#docker安装---通过其完整的软件包名称安装特定版本
echo "Please enter the version number of docker(e.g. 19.03.5):"
read version
echo "准备安装docker.........."
yum install docker-ce-$version docker-ce-cli-$version containerd.io
echo "docker安装完毕.........."
 
#docker安装---查看当前docker的版本信息
echo "---------- docker versionInfo ----------"
docker version
echo "----------//dockerversionInfo ----------"
 
#docker安装---启动docker
systemctl start docker
echo "docker已启动.........."
 
#拉取openstf镜像
echo "拉取openstf镜像......"
docker pull openstf/stf:latest
 
#拉取adb镜像
echo "拉取adb镜像......."
docker pull sorccu/adb:latest
 
#拉取ambassador镜像
echo "拉取ambassador镜像......."
docker pull openstf/ambassador:latest
 
#拉取rethinkdb数据库镜像
echo "拉取rethinkdb数据库镜像......."
docker pull rethinkdb:latest
 
#拉取nginx镜像
echo "拉取nginx镜像........"
docker pull nginx:latest
 
#启动数据库
echo "正在启动数据库......"
docker run -d --name rethinkdb -v /srv/rethinkdb:/data --net host rethinkdb rethinkdb --bind all --cache-size 8192 --http-port 8090
echo "数据库启动完成......."
 
#启动adb service
echo "正在启动adb......."
docker run -d --name adbd --privileged -v /dev/bus/usb:/dev/bus/usb/ --net host sorccu/adb:latest
echo "adb启动完成......."
 
#启动stf
echo "正在启动stf......."
docker run -d --name stf --net host openstf/stf stf local --public-ip $IP
echo "stf启动完成......."