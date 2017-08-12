#!/bin/bash

if [[ -f gogs.conf ]]; then
  read -r -p "A config file exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv gogs.conf gogs.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

if [ -z "$GOGS_HOSTNAME" ]; then
  read -p "Hostname (FQDN): " -ei "gogs.example.org" GOGS_HOSTNAME
fi

[[ -a /etc/timezone ]] && TZ=$(cat /etc/timezone)
if [ -z "$TZ" ]; then
  read -p "Timezone: " -ei "Europe/Berlin" TZ
else
  read -p "Timezone: " -ei ${TZ} TZ
fi

cat << EOF > gogs.conf
# ------------------------------
# gogs web ui configuration
# ------------------------------
# example.org is _not_ a valid hostname, use a fqdn here.
# Default admin user is "???"
# Default password is "???"
GOGS_HOSTNAME=${GOGS_HOSTNAME}

# ------------------------------
# SQL database configuration
# ------------------------------
DBNAME=gogs
DBUSER=gogs

# Please use long, random alphanumeric strings (A-Za-z0-9)
DBPASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
DBROOT=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# ------------------------------
# HTTP/S Bindings
# ------------------------------

# You should use HTTPS, but in case of SSL offloaded reverse proxies:
HTTP_PORT=80
HTTP_BIND=0.0.0.0

HTTPS_PORT=443
HTTPS_BIND=0.0.0.0

SSH_PORT=10022
SSH_BIND=0.0.0.0

# Your timezone
TZ=${TZ}

# Fixed project name
COMPOSE_PROJECT_NAME=gogs

EOF

#mkdir -p data/assets/ssl

# copy but don't overwrite existing certificate
#cp -n data/assets/ssl-example/*.pem data/assets/ssl/

