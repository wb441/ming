#!/bin/bash
# Conditional subdomain configuration based on environment variables

echo "Configuring SWAG subdomains..."

# Create proxy-confs directory if it doesn't exist
mkdir -p /config/nginx/proxy-confs

# Array of subdomains
declare -A subdomains=(
  [ENABLE_HOMEASSISTANT]="homeassistant.subdomain.conf"
  [ENABLE_GRAFANA]="grafana.subdomain.conf"
  [ENABLE_INFLUXDB]="influxdb.subdomain.conf"
  [ENABLE_NODERED]="nodered.subdomain.conf"
  [ENABLE_JUPYTERLAB]="jupyterlab.subdomain.conf"
  [ENABLE_DUPLICATI]="duplicati.subdomain.conf"
  [ENABLE_PORTAINER]="portainer.subdomain.conf"
)

# Process each subdomain
for env_var in "${!subdomains[@]}"; do
  config_file="${subdomains[$env_var]}"
  env_value="${!env_var}"
  
  # Default to enabled (true) if not specified
  if [ -z "$env_value" ]; then
    env_value="true"
  fi
  
  config_path="/config/nginx/proxy-confs/$config_file"
  
  if [ "$env_value" = "true" ]; then
    if [ -f "/defaults/proxy-confs/$config_file" ]; then
      echo "Enabling: $config_file"
      cp "/defaults/proxy-confs/$config_file" "$config_path"
    fi
  else
    # Remove config if disabled
    if [ -f "$config_path" ]; then
      echo "Disabling: $config_file"
      rm "$config_path"
    fi
  fi
done

echo "Subdomain configuration complete"

# Call the original SWAG entrypoint
exec /init
