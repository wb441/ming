# MING (Mosquitto, InfluxDB, NodeRed, Grafana)

MING is a containerised IoT sensor server stack in the traditions of LAMP.

We've leveraged #OpenBalena to provide a embedded Linux environment to provide:

- **SWAG** (Secure Web Application Gateway) - Reverse proxy with SSL/TLS support listening on ports 80/443, providing secure access to all web services

- **Mosquitto** - MQtt broker listening on port 1883 for MQtt message publications

- **InfluxDB** - Time series database listening on port 8086 for sensor data storage

- **Node-RED** - Flow-based programming environment listening on port 1880 for parsing, analysing, storing, and forwarding sensor data messages
  
  We've also installed the Node-RED InfluxDB nodes by default so you can easily store and retrieve data locally.

- **Grafana** - Data visualisation dashboard listening on port 3000

- **Home Assistant** - Open source home automation platform listening on port 8123

- **JupyterLab** - Interactive computing environment listening on port 8888

- **Duplicati** - Backup solution listening on port 8200 for automated backups of all service data

Each of these applications is built and runs in its own container on an embedded Linux target supporting Balena.io (Docker for Embedded Systems).

## Accessing Services

All web services are accessible through the SWAG reverse proxy at the following subdirectories:

- Home Assistant: `https://yourdomain.com/homeassistant/`
- Node-RED: `https://yourdomain.com/nodered/`
- Grafana: `https://yourdomain.com/grafana/`
- InfluxDB: `https://yourdomain.com/influxdb/`
- JupyterLab: `https://yourdomain.com/jupyterlab/`
- Duplicati: `https://yourdomain.com/duplicati/`

Services are also accessible directly via their individual ports if needed.

# Configuration

## SWAG Reverse Proxy Setup

Before deploying, you'll need to configure SWAG in [`docker-compose.yml`](docker-compose.yml):

1. Set your domain: Change `URL=yourdomain.com` to your actual domain
2. Configure validation method: Set `VALIDATION` to your preferred method (http, dns, etc.)
3. For SSL certificates, you may need to configure additional DNS or port forwarding settings

## Home Assistant Configuration

To enable Home Assistant to work properly behind the SWAG reverse proxy, add the following to `/config/configuration.yaml` in your Home Assistant container:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.18.0.0/16
```

# Optional Components

We've added some nice applications that can be optionally enabled by uncommenting them in the [`docker-compose.yml`](docker-compose.yml) file in this repo

These components are:

## [Rhasspy](https://rhasspy.readthedocs.io/en/latest/)

Rhasspy (pronounced RAH-SPEE) is an open source, fully offline voice assistant toolkit for many languages that works well with Home Assistant, Hass.io, and Node-RED.

## [Wifi-Connect](https://github.com/balena-io/wifi-connect) (AP Mode)

This is only available when using Balena. It allows you to create a Wifi Access Point on a device with AP capable hardware such as a Raspberry Pi 3, simply uncomment the docker-compose SERVICE labelled "ap" and set `MING_AP` to a value of `1` in your [Balena device variables or service variables](#configure-via-environment-variables).

## Enabling these optional components

To enable [Rhasspy](https://rhasspy.readthedocs.io/en/latest/) for example, uncomment it in [`docker-compose.yml`](docker-compose.yml)

Enabled ✔
```
  rhasspy:
    restart: always
    build: ./rhasspy
    ports:
      - "12101:12101"
    volumes:
      - 'rhasspy-data:/profiles'
    devices:
      - "/dev/snd:/dev/snd"
    command: --user-profiles /profiles --profile en
```
Disabled ✖
```
#  rhasspy:
#    restart: always
#    build: ./rhasspy
#    ports:
#      - "12101:12101"
#    volumes:
#      - 'rhasspy-data:/profiles'
#    devices:
#      - "/dev/snd:/dev/snd"
#    command: --user-profiles /profiles --profile en
```

# Supported Targets

Currently tested targets are

- Intel NUC (which can be used for testing with QEMUx86_64)

Example command: Note the host to guest port forwarding

```sudo qemu-system-x86_64 -drive file=balena-cloud-IntelNucTest-qemux86-64-2.38.0+rev1-dev-v9.15.7.img,media=disk,cache=none,format=raw -net nic,model=virtio -net user,hostfwd=tcp::5880-:1880,hostfwd=tcp::5000-:3000,hostfwd=tcp::5883-:1883,hostfwd=tcp::5884-:1884 -m 1024 -nographic -machine type=pc,accel=kvm -smp 4 -cpu host```

You may need to increase the size of the qemu image download you get from Balena.io:

```qemu-img resize balena-cloud-IntelNucTest-qemux86-64-2.38.0+rev1-dev-v9.15.7.img -f raw +10G```

This will be picked up when the image boots and the partition/filesystem resized accordingly

- Raspberry Pi 3 B+

- Raspberry Pi Zero may work [TBD]

# Getting going

Clone this repository and follow getting started instructions at Balena.io

Either start with a Raspberry Pi 3B+, [here](https://www.balena.io/os/docs/raspberrypi3/getting-started)

Or you might choose so test with a VirtualBox VM, [here](https://www.balena.io/blog/no-hardware-use-virtualbox)

Add the remote from the Balena.io dashboard to this repo and do a git push.

Balena.io will build and deploy the containers to your target.

It's that easy!

## Configure via [environment variables](https://docs.resin.io/management/env-vars/)
Variable Name | Value | Description | Default
------------ | ------------- | ------------- | -------------
**`JUPYTER_MING_PASS`** | `STRING` | the password Jupyter Labs will start up with | mingstack
**`MING_AP`** | `1` OR `0` | Whether to start a Wifi AP or not, 0 = off, 1 = on  | 0

# More detail

Here's an example of what you will see on the Balena dashboard.

You can see the individual containers running, the unique ID (UID) of the newly registered device,
and it's local IP address. You can also enable a public URL to access the device remotely. By default
if you enable access to port 80 you'll enable access to the Grafana server.

![](https://i.ibb.co/jvxDcNr/Screenshot-from-2019-10-13-18-46-32.png)

You can see from the above that the short form of the UID for this device is e844144.

You can change this but for now if you attempt to ping that UID you should have connectivity

`$ ping e844144.local`

If you run into problems just try pinging to the local IP address you see on the dashboard 

`$ ping 192.168.0.228`

With connectivity working you can now take a look at the servers running on the target.

## Through SWAG Reverse Proxy (Recommended)

Access all services securely through SWAG at https://e844144.local/ (or your configured domain):

- Home Assistant: https://e844144.local/homeassistant/
- Node-RED: https://e844144.local/nodered/
- Grafana: https://e844144.local/grafana/ (default password: admin, admin)
- InfluxDB: https://e844144.local/influxdb/
- JupyterLab: https://e844144.local/jupyterlab/
- Duplicati: https://e844144.local/duplicati/

## Direct Port Access

You can also access services directly via their ports:

- Node-RED: http://e844144.local:1880

![](https://i.ibb.co/pPMRkgS/Screenshot-from-2019-10-13-19-00-18.png)

- Grafana: http://e844144.local:3000 (default password: admin, admin)

![](https://i.ibb.co/rZ8C1qD/Screenshot-from-2019-10-13-19-00-54.png)

- Home Assistant: http://e844144.local:8123
- JupyterLab: http://e844144.local:8888
- InfluxDB: http://e844144.local:8086
- Duplicati: http://e844144.local:8200
- Mosquitto MQTT: tcp://e844144.local:1883

# Maintainer / Contributors

- Alex J Lennon (@embedded_iot)
- Julian Todd (@goatchurch)
- Matthew Croughan (@matthewcroughan)

# Attribution

- This is in part based on excellent work done by the Balena.io team

@see: https://github.com/balena-io-projects/balena-sense

# Contributing

Please raise issues and generate PRs at

https://github.com/DynamicDevices/ming
