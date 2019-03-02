# docker-digibyte
Docker Image for Digibyte using Digibyte Client

### Quick Start
Create a dgb-data volume to persist the bchd blockchain data, should exit immediately. The dgb-data container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):
```
docker volume create --name=dgb-data
```
Create a digibyte.conf file and put your configurations
```
mkdir -p .dgbdocker
nano /home/$USER/.dgbdocker/digibyte.conf
```

Run the docker image
```
docker run -v dgb-data:/digibyte --name=dgb-node -d \
      -p 12024:12024 \
      -p 14022:14022 \
      -v /home/$USER/.dgbdocker/digibyte.conf:/digibyte/.digibyte/digibyte.conf \
      unibtc/docker-digibyte:6.17.2
```

Check Logs
```
docker logs -f dgb-node
```

Auto Installation
```
sudo bash -c "$(curl -L https://git.io/fhAyK)" -- 6.17.2
```
