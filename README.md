Dockerfile for the docker image with sentinel-cli dvpn : https://hub.docker.com/repository/docker/cyberpoison/sentinel-client-cli/general

More documentation shortly

Some improvement and documentation from external sources

Go to docker exec and do:
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

Then follow tutorial here: https://standardvpn.com/dvpn-cli/

As you will need documentation also here: https://docs.sentinel.co/sentinel-cli

You need to run container as privilegied:

I'm running this container on e k8s stack so to get a overview of the config in k8s / yaml 
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

This docker image is working.
