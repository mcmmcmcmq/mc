#!/bin/bash
# export http_proxy="127.0.0.1:871"
# export https_proxy=$http_proxy
# export socks5_proxy="socks5://127.0.0.1:870"
echo "代理设置完毕"
node_install_path="/opt/node-v12.16.1-linux-x64/"

# 安装rclone
installRclone() {
    cd ~
    echo "正在安装rclone..."
    wget https://downloads.rclone.org/v1.57.0/rclone-v1.57.0-linux-amd64.zip
    unzip rclone-v1.57.0-linux-amd64.zip
    mv rclone-v1.57.0-linux-amd64 rclone
    cd rclone
    chmod +x ./rclone
    mv ./rclone /usr/sbin/
    mkdir -p ~/.config/rclone/
    echo "[mcserver]
type = dropbox
token = ${DropBoxToken}" >>~/.config/rclone/rclone.conf
}
# 安装环境
installNode() {
    mkdir -p ${node_install_path}
    cd ${node_install_path}
    sleep 3

    # node
    wget https://npm.taobao.org/mirrors/node/v12.16.1/node-v12.16.1-linux-x64.tar.gz

    # Unpack
    echo "Unpacking..."
    echo "> tar -zxf node-v12.16.1-linux-x64.tar.gz"
    tar -zxf node-v12.16.1-linux-x64.tar.gz
    rm -rf node-v12.16.1-linux-x64.tar.gz
    echo "complete."

    sleep 1

    echo "Linking..."
    echo "> ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/node /usr/bin/node"
    echo "> ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/node /usr/bin/node"
    rm -rf /usr/bin/node /usr/bin/npm
    ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/node /usr/bin/node
    ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/npm /usr/bin/npm
    echo "complete."
}
#安装服务端
installMCSmanager() {
    cd ~
    echo "正在下载管理界面"
    git clone https://github.com/xhuanya/heroku-mcmanager.git "AllCode"
    mv ./AllCode/Manager ./Manager
    rm -rf ./AllCode
}
# 检查服务端是否存在
checkIsInstall() {
    checkServerHas=$(rclone ls mcserver:/ --cache-db-purge)
    if [[ "${checkServerHas}" == *"mcserver/backups.tar.gz"* ]]; then
        echo "存在"
        # 备份到home
        rclone copy mcserver:/mcserver/backups.tar.gz ~
        flag=1
        while [ $flag -eq 1 ]; do
            sleep 10s
            if [ ! -f "~/Manager/backups.tar.gz" ]; then
                flag=0
                echo "备份文件下载成功正在解压。。。。"
                cd
                tar -xvf ~/backups.tar.gz -C ~/
            else
                echo "文件不存在"
            fi
        done

    else
        echo "不存在"
        installMCSmanager
    fi
}
start() {
    cd ~/Manager/
    npm install

    nohup npm start >./manager.log 2>&1 &
}

autoBak() {
    echo "备份已开启 首次运行将在180s后备份"
    sleep 180s
    echo "正在备份"
    tar -cvf ~/backups.tar.gz ~/Manager
    rclone copy ~/backups.tar.gz mcserver:/mcserver/
    while [ 1==1 ]; do

        sleep 1h
        echo "正在备份"
        tar -cvf ~/backups.tar.gz ~/Manager
        rclone copy ~/backups.tar.gz mcserver:/mcserver/

    done
}
vpn() {
    /app/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
    until /app/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=${APPNAME} --advertise-tags=tag:mcserver; do
        sleep 0.1
    done
    echo Tailscale started
    ALL_PROXY=socks5://localhost:1055/ /app/my-app
}
frp(){
    cd ~
    wget -O ./frp.tar.gz https://github.com/fatedier/frp/releases/download/v0.42.0/frp_0.42.0_linux_386.tar.gz
    tar -xzvf ./frp.tar.gz
    echo ${FRP}>~/frp_0.42.0_linux_386/frpc.ini
      until ~/frp_0.42.0_linux_386/frpc; do
        sleep 0.1
    done

}

# 安装
installNode
installRclone
checkIsInstall
start
if [[ -n "${TAILSCALE_AUTHKEY}" ]]; then
vpn
fi
if [[ -n "${FRP}" ]]; then
frp
fi
autoBak
