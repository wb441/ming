# Home Assistant Configuration for Reverse Proxy

After your Home Assistant container starts for the first time, you need to configure it to work behind the SWAG reverse proxy.

## Configuration Steps

1. Access Home Assistant directly at: `http://<device-ip>:8123`

2. Complete the initial setup wizard

3. Add the following to your `configuration.yaml` file:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.16.0.0/12
```

**Note**: The `172.16.0.0/12` range covers typical Docker network subnets and includes your SWAG container's IP address.

4. Restart Home Assistant

## Accessing Home Assistant

- **Direct access**: `http://<device-ip>:8123`
- **Via SWAG subfolder**: `https://yourdomain.com/homeassistant/`
- **Recommended**: Use a subdomain like `https://ha.yourdomain.com` for best compatibility

## Troubleshooting

If you see "Unable to connect" or redirect issues:
- Verify the `trusted_proxies` configuration is correct
- Check that SWAG and Home Assistant containers can communicate
- Use direct access on port 8123 to verify Home Assistant is running
- Check logs: `balena logs homeassistant`

## Note on Subfolder Access

Home Assistant works best with a subdomain rather than a subfolder path. If you continue to have issues with `/homeassistant/`, consider using a subdomain configuration instead.
