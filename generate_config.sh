#!/bin/bash

if [[ -f gogs.conf ]]; then
  read -r -p "config file gogs.conf exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv gogs.conf gogs.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

if [ -z "$PUBLIC_FQDN" ]; then
  read -p "Hostname (FQDN): " -ei "gogs.example.org" PUBLIC_FQDN
fi

if [ -z "$ADMIN_MAIL" ]; then
  read -p "Gogs admin Mail address: " -ei "mail@example.com" ADMIN_MAIL
fi

[[ -f /etc/timezone ]] && TZ=$(cat /etc/timezone)
if [ -z "$TZ" ]; then
  read -p "Timezone: " -ei "Europe/Berlin" TZ
fi


DBNAME=gogs
DBUSER=gogs
DBPASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

HTTP_PORT=3000
SSH_PORT=10022


cat << EOF > gogs.conf
# ------------------------------
# gogs web ui configuration
# ------------------------------
# example.org is _not_ a valid hostname, use a fqdn here.
PUBLIC_FQDN=${PUBLIC_FQDN}

# ------------------------------
# GOGS admin user
# ------------------------------
GOGS_ADMIN=gogsadmin
ADMIN_MAIL=${ADMIN_MAIL}
GOGS_PASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# ------------------------------
# SQL database configuration
# ------------------------------
DBNAME=${DBNAME}
DBUSER=${DBUSER}

# Please use long, random alphanumeric strings (A-Za-z0-9)
DBPASS=${DBPASS}
DBROOT=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# ------------------------------
# Bindings
# ------------------------------

# You should use HTTPS, but in case of SSL offloaded reverse proxies:
HTTP_PORT=${HTTP_PORT}
HTTP_BIND=0.0.0.0

HTTPS_PORT=443
HTTPS_BIND=0.0.0.0

SSH_PORT=${SSH_PORT}
SSH_BIND=0.0.0.0

# Your timezone
TZ=${TZ}

# Fixed project name
#COMPOSE_PROJECT_NAME=gogs

EOF

mkdir -p data/gogs/gogs/conf

if [[ -f ./data/gogs/gogs/conf/app.ini ]]; then
  read -r -p "config file app.ini exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv ./data/gogs/gogs/conf/app.ini ./data/gogs/gogs/conf/app.ini_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

cat << EOF > data/gogs/gogs/conf/app.ini
APP_NAME = Gogs
RUN_USER = git
RUN_MODE = prod

[database]
DB_TYPE  = mysql
HOST     = dc_gogs_db:3306
NAME     = ${DBNAME}
USER     = ${DBUSER}
PASSWD   = ${DBPASS}
SSL_MODE = disable
PATH     = data/gogs.db

[repository]
ROOT = /data/gogs/gogs-repositories
FORCE_PRIVATE = true

[server]
DOMAIN           = ${PUBLIC_FQDN}
HTTP_PORT        = ${HTTP_PORT}
ROOT_URL         = http://${PUBLIC_FQDN}:${HTTP_PORT}/
DISABLE_SSH      = false
SSH_PORT         = ${SSH_PORT}
START_SSH_SERVER = true
OFFLINE_MODE     = false

[mailer]
ENABLED = false

[service]
REGISTER_EMAIL_CONFIRM = false
ENABLE_NOTIFY_MAIL     = false
DISABLE_REGISTRATION   = true
ENABLE_CAPTCHA         = true
REQUIRE_SIGNIN_VIEW    = true

[picture]
DISABLE_GRAVATAR        = false
ENABLE_FEDERATED_AVATAR = true

[session]
PROVIDER = file

[log]
MODE      = file
LEVEL     = Info
ROOT_PATH = /app/gogs/log

[security]
INSTALL_LOCK = true
SECRET_KEY   = OZOA7nGam9HsoyI

EOF


