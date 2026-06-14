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

All web services are accessible through the SWAG reverse proxy via subdomains:

- Home Assistant: `https://homeassistant.yourdomain.com/` (or via subdomain config)
- Node-RED: `https://nodered.yourdomain.com/`
- Grafana: `https://grafana.yourdomain.com/`
- InfluxDB: `https://influxdb.yourdomain.com/`
- JupyterLab: `https://jupyterlab.yourdomain.com/`
- Duplicati: `https://duplicati.yourdomain.com/`
- Portainer: `https://portainer.yourdomain.com/`

Services are also accessible directly via their individual ports if needed.

### Testing Subdomains Locally

When testing locally without a real domain, you have several options:

1. **Using UniFi Gateway DNS** (Recommended)
   - Add local DNS A records in your UniFi gateway pointing subdomains to your device IP
   - Add two records:
     - **Type**: A, **Name**: `morningfrog.home.arpa`, **IP**: `192.168.0.15`
     - **Type**: A, **Name**: `*.morningfrog.home.arpa`, **IP**: `192.168.0.15`
   - (Replace `morningfrog.home.arpa` with your actual domain and `192.168.0.15` with your device IP)
   - Then access via browser normally: `https://morningfrog.home.arpa/` and `https://homeassistant.morningfrog.home.arpa/`

2. **Using Windows hosts file**
   - Edit `C:\Windows\System32\drivers\etc\hosts` and add:
     ```
     192.168.0.15  morningfrog.home.arpa
     192.168.0.15  homeassistant.morningfrog.home.arpa
     192.168.0.15  nodered.morningfrog.home.arpa
     192.168.0.15  grafana.morningfrog.home.arpa
     ```
   - Access via browser: `https://morningfrog.home.arpa/` (accept SSL warning for self-signed cert)

3. **Using curl with Host headers**
   - `curl -k -H "Host: homeassistant.morningfrog.home.arpa" https://192.168.0.15/`

# Configuration

## Duplicati

The minimal configuration needed:

```yaml
environment:
  - SETTINGS_ENCRYPTION_KEY=duplicati
  - PASSWORD=password
```

when changing these, you need to purge the data.

## SWAG Reverse Proxy Setup

SWAG provides SSL/TLS encrypted access to all web services via subdomains. Configuration is handled via environment variables in `docker-compose.yml`.

### Normal environmental variables

```yaml
environment:
  - ENABLE_HOMEASSISTANT=true #or other ones
  - DIRECT_HOST=%%BALENA_DEVICE_UUID%%.local
```

### Testing Configuration (HTTP, self-signed certificate)

The default configuration uses self-signed certificates for testing:

```yaml
environment:
  - URL=localhost
  - CERTPROVIDER=
  - VALIDATION=
```

when changing these, you need to purge the data.

This mode:
- Uses self-signed certificates (warning in browser is normal)
- Works with local testing via UniFi DNS, hosts file, or curl
- No external domain or certificate validation needed

### Production Configuration (Let's Encrypt with DuckDNS)

To use production SSL certificates, update the environment variables:

```yaml
environment:
  - URL=yourdomain.duckdns.org
  - VALIDATION=duckdns
  - DUCKDNSTOKEN=your-duckdns-token
  - CERTPROVIDER=letsencrypt
```

Then:
1. Set `DUCKDNSTOKEN` to your actual DuckDNS token
2. Ensure port forwarding is configured for ports 80/443
3. Set `STAGING=false` for production certificates (after testing)

when changing these, you need to purge the data.

### Enabling/Disabling Individual Subdomains

Each subdomain proxy can be enabled or disabled via environment variables in `docker-compose.yml`:

```yaml
environment:
  - ENABLE_HOMEASSISTANT=true
  - ENABLE_GRAFANA=true
  - ENABLE_INFLUXDB=true
  - ENABLE_NODERED=true
  - ENABLE_JUPYTERLAB=true
  - ENABLE_DUPLICATI=true
  - ENABLE_PORTAINER=true
```

Set to `false` to disable any service. This is useful for testing or when services aren't deployed. Restart SWAG after changes:

```bash
balena restart <device-uuid> swag
```

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

### SWAG Configuration
Variable Name | Value | Description | Default
------------ | ------------- | ------------- | -------------
**`URL`** | `STRING` | Domain name (e.g., yourdomain.duckdns.org) | localhost
**`VALIDATION`** | `http`, `duckdns`, or empty | Certificate validation method | (empty for self-signed)
**`DUCKDNSTOKEN`** | `STRING` | DuckDNS token for DNS validation | (not set)
**`CERTPROVIDER`** | `letsencrypt` or empty | Certificate provider | (empty for self-signed)
**`ENABLE_HOMEASSISTANT`** | `true` or `false` | Enable Home Assistant subdomain | true
**`ENABLE_GRAFANA`** | `true` or `false` | Enable Grafana subdomain | true
**`ENABLE_INFLUXDB`** | `true` or `false` | Enable InfluxDB subdomain | true
**`ENABLE_NODERED`** | `true` or `false` | Enable Node-RED subdomain | true
**`ENABLE_JUPYTERLAB`** | `true` or `false` | Enable JupyterLab subdomain | true
**`ENABLE_DUPLICATI`** | `true` or `false` | Enable Duplicati subdomain | true
**`ENABLE_PORTAINER`** | `true` or `false` | Enable Portainer subdomain | true

### Other Services
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

## Through SWAG Reverse Proxy (Recommended for Production)

Access all services securely through SWAG via subdomains (requires domain setup):

- Home Assistant: `https://homeassistant.yourdomain.com/`
- Node-RED: `https://nodered.yourdomain.com/`
- Grafana: `https://grafana.yourdomain.com/` (default password: admin, admin)
- InfluxDB: `https://influxdb.yourdomain.com/`
- JupyterLab: `https://jupyterlab.yourdomain.com/`
- Duplicati: `https://duplicati.yourdomain.com/`
- Portainer: `https://portainer.yourdomain.com/`

## For Testing (Local Access)

When testing with a self-signed certificate, access via:
- Base URL: `https://e844144.local/` or `https://192.168.0.228/`
- Note: Browser will show SSL warning (expected for self-signed certificates)

To access specific subdomains locally:
1. Set up DNS records in UniFi gateway (recommended)
2. Or add entries to Windows hosts file
3. Or use curl with Host headers (see "Testing Subdomains Locally" section in README)

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

# Known Issues & Troubleshooting

## Services Not Responding Through SWAG

**Symptom**: `Connection refused` on port 80/443

**Solutions**:
1. Verify SWAG is running: `balena logs <device-uuid> -s swag`
2. Check certificate generation succeeded (look for errors in logs)
3. For testing, ensure `VALIDATION` and `CERTPROVIDER` are empty or set to `http`
4. Verify upstream services are running and responding on their ports

## Subdomain DNS Not Resolving

**Symptom**: `DNS_PROBE_FINISHED_NXDOMAIN` when accessing subdomains

**Solutions**:
1. Set up DNS A records in UniFi gateway (recommended)
2. Use Windows hosts file entries
3. Use curl with Host headers for testing
4. For production, ensure DuckDNS domain is properly configured

## CAN Interface Errors (roconmqtt/setup-can crashing)

**Symptom**: Services repeatedly crashing if CAN hardware isn't present

**Solution**: This is expected behavior - `setup-can` and `roconmqtt` are set to `restart: no` so they exit gracefully when hardware is unavailable. They won't continuously restart.

To manually start them once hardware is available:
```bash
balena start <device-uuid> roconmqtt
```

## Service Crashes on Startup

**Common causes**:
- Check logs for the specific service: `balena logs <device-uuid> -s <service-name>`
- Verify all volumes have proper permissions
- For SWAG: ensure nginx config syntax is valid
- Restart SWAG after disabling subdomains: `balena restart <device-uuid> swag`

