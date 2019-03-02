#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi

VERSION="${1:-latest}"
echo "Installing Digibyte $VERSION Docker"

mkdir -p $HOME/.dgbdocker

echo "Initial Digibyte Configuration"

read -p 'rpcuser: ' rpcuser
read -p 'rpcpassword: ' rpcpassword

echo "Creating Digibyte configuration at $HOME/.dgbdocker/digibyte.conf"

cat >$HOME/.dgbdocker/digibyte.conf <<EOL
server=1
listen=1
rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcport=8432
rpcthreads=4
dbcache=8000
par=0
port=8433
rpcallowip=127.0.0.1
rpcallowip=$(curl -s https://canihazip.com/s)
printtoconsole=1
EOL

echo Installing Digibyte Container

docker volume create --name=dgb-data
docker run -v dgb-data:/digibyte --name=dgb-node -d \
      -p 12024:12024 \
      -p 14022:14022 \
      -v $HOME/.dgbdocker/digibyte.conf:/digibyte/.digibyte/digibyte.conf \
      bitsler/docker-digibyte:$VERSION

echo "Creating shell script"

cat >/usr/bin/dgb-cli <<'EOL'
#!/usr/bin/env bash
docker exec -it dgb-node /bin/bash -c "digibyte-cli $*"
EOL

cat >/usr/bin/cgb-update <<'EOL'
#!/usr/bin/env bash
set -e
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
VERSION="${1:-latest}"
echo "Stopping digibyte ..."
dgb-cli stop
echo "Waiting digibyte gracefull shutdown..."
docker wait dgb-node
echo "Updating digibyte ..."
docker pull bitsler/docker-digibyte:$VERSION
echo "Removing old digibyte installation"
docker rm dgb-node
echo "Running new digibyte container"
docker run -v dgb-data:/digibyte --name=dgb-node -d \
      -p 12024:12024 \
      -p 14022:14022 \
      -v $HOME/.dgbdocker/digibyte.conf:/digibyte/.digibyte/digibyte.conf \
      bitsler/docker-digibyte:$VERSION

echo "Digibyte successfully updated and started"
echo ""
EOL

cat >/usr/bin/dgb-rm <<'EOL'
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
echo "WARNING! This will delete ALL dgb-docker installation and files"
echo "Make sure your wallet.dat is safely backed up, there is no way to recover it!"
function uninstall() {
  sudo docker stop dgb-node
  sudo docker rm dgb-node
  sudo rm -rf ~/docker/volumes/dgb-data ~/.dgbdocker /usr/bin/dgb-cli
  sudo docker volume rm dgb-data
  echo "Successfully removed"
  sudo rm -- "$0"
}
read -p "Continue (Y)?" choice
case "$choice" in
  y|Y ) uninstall;;
  * ) exit;;
esac
EOL

chmod +x /usr/bin/dgb-cli
chmod +x /usr/bin/dgb-rm

echo
echo "==========================="
echo "==========================="
echo "Installation Complete"
echo "You can now run normal dgb-cli commands"
echo "Your configuration file is at $HOME/.dgbdocker/digibyte.conf"
echo "If you wish to change it, make sure to restart dgb-node"
echo "IMPORTANT: To stop dgb-node gracefully, use 'dgb-cli stop' and wait for the container to stop to avoid corruption"