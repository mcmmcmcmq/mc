#!/bin/bash
zerotier-one -d
zerotier-cli join 8bd5124fd6bd3e02
node_install_path="/opt/node-v12.16.1-linux-x64/"

echo "Start to install MCSManager..."
echo ""
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

sleep 1

echo "--------------- Node Version ---------------"
node_version=`node -v`
npm_version=`npm -v`
echo " node: ${node_version}"
echo " npm: ${npm_version}"
echo "--------------- Node Version ---------------"


npm installvecho "complete."

sleep 3

echo "Start to install dependent libraries..."
cd /opt/Manager/
npm install
npm start