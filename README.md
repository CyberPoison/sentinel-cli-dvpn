![DVPN](https://assets.coingecko.com/coins/images/14879/standard/YMEMrc-V_400x400.jpg "DVPN")

## Docker of Sentinel-CLI Client DVPN 

#### ATTENTION: V2RAY is installed but not working need some time to understand how that soft works !!.

This repo contains: Dockerfile and Network Script, for the docker image with sentinel-cli dvpn : [https://hub.docker.com/r/cyberpoison/sentinel-client-cli-dvpn
](https://hub.docker.com/r/cyberpoison/sentinel-client-cli-dvpn)

More documentation shortly

Docker run command
```
docker run \
    --name dvpn \
    --restart=always \
    --env TZ=Europe/London \
    --privileged \
    --read-only=false \
    --volume "$(pwd)/.sentinel-wallet/:/root/.sentinelcli" \
    --network=bridge \
    cyberpoison/sentinel-client-cli-dvpn:latest \
    /bin/sh -c "/root/setup_network.sh"
```
then:
```
docker exec -it dvpn /bin/bash
```

### in case the script has not been executed you can run the below commands.
 
Go to docker container exec and do:
```
sysctl -w "net.ipv6.conf.all.disable_ipv6 = 0"
sysctl -w "net.ipv6.conf.all.disable_ipv6 = 0"
sysctl -w "net.ipv6.conf.default.disable_ipv6 = 0"
sysctl -w "net.ipv6.conf.lo.disable_ipv6 = 0"
```
to route the local packets to the other containers or to reach dockers network externally:
```
ip route add 127.0.0.1/8 dev lo
ip route add 10.0.0.0/8 dev eth0
ip route add 172.16.0.0/12 dev eth0
ip route add 192.168.0.0/16 dev eth0
ip route add 169.254.0.0/16 dev eth0
ip route add ::1/128 dev lo
ip route add fc00::/7 dev eth0
ip route add fe80::/10 dev eth0
ip route add ::ffff:7f00:1/104 dev lo
ip route add ::ffff:a00:0/104 dev eth0
ip route add ::ffff:a9fe:0/112 dev eth0
ip route add ::ffff:ac10:0/108 dev eth0
ip route add ::ffff:c0a8:0/112 dev eth0
```

More docs here: https://standardvpn.com/dvpn-cli/

Need documentation also ? It's here: https://docs.sentinel.co/sentinel-cli

#### Tags meanings:
```
<KEY_NAME>  = Wallet Name
<ACCOUNT_ADDRESS> = Your Wallet/account Address
<NODE_ADDRESS> = The Node you want to subscribe usually starts with "sentnode....."
<SUBSCRIPTION_ID> = Subscrition ID ? Your Subscription id on sentinel network
Memotic = Used to sign in on kepl extention and withdraw the DVPN crypto. And maybe for other things ....
```


## Seting Up documentation:
### Create a account wallet
```
sentinelcli keys add \
    --home "${HOME}/.sentinelcli" \
    --keyring-backend file \
    <KEY_NAME> 
```
### PLEASE SAVE THE MEMOTIC (IT'S AT THE BOTTOM BEFORE THE PROMPT SHELL) IT WILL BE NOT POSSIBLE TO RECOVER IT, SO SAVE IT IN A SAFE PLACE !!.

save also the wallet/account addess you will need it in the future steps :)  

if you want you can use: [https://map.sentinel.co/](https://map.sentinel.co/) to select your node
```
sentinelcli query nodes \
    --home "${HOME}/.sentinelcli" \
    --node https://rpc.trinityvalidator.com:443 \
    --page 1
```

### INFO
Please ensure that you select one option between `<gigabytes>` and `<hours>`. The unused option should be assigned a value of 0.

Use: [https://map.sentinel.co/](https://map.sentinel.co/) to select your node if you want.

```
sentinelcli tx node subscribe \
  <sentnode_address> \
  <gigabytes> \
  <hours> \
  udvpn \
  --from  <KEY_NAME>  \
  --chain-id=sentinelhub-2 \
  --node https://rpc.trinityvalidator.com:443 \
  --gas-prices=0.5udvpn \
  --gas=300000 \
  --keyring-backend file
```

### Get your subscrition id:
```
sentinelcli query subscriptions \
    --home "${HOME}/.sentinelcli" \
    --node https://rpc.trinityvalidator.com:443 \
    --page 1 \
    --address <ACCOUNT_ADDRESS>
```
### Connect to node as client 🚀
```
sudo sentinelcli connect \
    --home "${HOME}/.sentinelcli" \
    --keyring-backend file \
    --chain-id sentinelhub-2 \
    --node https://rpc.trinityvalidator.com:443 \
    --gas-prices 0.1udvpn \
    --yes \
    --from <KEY_NAME> <SUBSCRIPTION_ID> <NODE_ADDRESS>
```

### Disconnect: ⚠️
```
sudo sentinelcli disconnect \
    --home "${HOME}/.sentinelcli"
```

You need to run container as privilegied:

I'm running this container on a k8s stack so to get a overview of the config in k8s / yaml 
```
apiVersion: apps/v1
kind: Deployment
metadata:
      manager: kube-controller-manager
      operation: Update
      subresource: status
  name: dvpn
  namespace: vpn
  resourceVersion: {}
  uid: {}
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector: {}
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      annotations:
        cattle.io/timestamp: '2023-09-08T05:11:08Z'
      creationTimestamp: null
      labels:
        app: ottfr
        tier: api
      namespace: ott
    spec:
      containers:
        - args:
            - '-f'
            - /dev/null
          command:
            - tail
          env:
            - name: TZ
              value: Europe/London
          image: cyberpoison/sentinel-client-cli:amd64
          imagePullPolicy: Always
          name: container-0
          resources: {}
          securityContext:
            capabilities:
              add:
                - NET_BIND_SERVICE
                - NET_RAW
                - SETPCAP
                - NET_BROADCAST
                - SYS_CHROOT
                - DAC_OVERRIDE
                - NET_ADMIN
                - SYS_MODULE
            privileged: true
            readOnlyRootFilesystem: false
            runAsNonRoot: false
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          volumeMounts:
            - mountPath: /root/.sentinelcli
              name: sentinell-wallet
      dnsPolicy: ClusterFirst
      imagePullSecrets:
        - name: docker-hub-secrets
      nodeName: hcloud-worker-1
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
        - hostPath:
            path: /mnt/.sentinel-wallet/
            type: DirectoryOrCreate
          name: sentinell-wallet
```

All this work is under GPL Domain :) 

Code will be commited shortly as soon i have managed getting it working on kubernetes, btw the container it self is giving already a node dvpn sentinell ip :) 🚀🚀

This docker image is working only with **wireguard** .


