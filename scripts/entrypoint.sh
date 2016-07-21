set -e

database_host="$POSTGRES_PORT_5432_TCP_ADDR"
database_port="$POSTGRES_PORT_5432_TCP_PORT"
database_user="$POSTGRES_ENV_POSTGRES_USER"
database_password="$POSTGRES_ENV_POSTGRES_PASSWORD"

if [[ -z "$VIRTUAL_HOST" ]]; then
  hostname='localhost'
else
  hostname="$VIRTUAL_HOST"
fi

if [[ -z "$TIMEZONE" ]]; then
  timezone='UTC'
else
  timezone="$TIMEZONE"
fi

if [[ -z "$SECRETKEY" ]]; then
  secretkey='fPxrF5PpzRMnaauVsbFr5KQ5Yyd6zVPbcrjz2Q4WzRZw2Bu9tvghauUk66i763SCnr3KY4PwpZv7rcZ3VvfXMdZhdLD6KCbSBGe4kFewJetd5sU5o7yDbpnVYxAGsUFR5KxaCSPT4D27MDxm4RJNtHtfpkuM4uwXfG3VpAoTxRszrpfrtRdBeNucPDnDWLjCHMSTNJs8BDXTonSgCQc9TZNCycM2Nfbpr4sTntAa3NyyR5CTEANdVp6YJYNwHk8e'
else
  secretkey="$SECRETKEY"
fi

python='/usr/bin/python2.7'
uwsgi='/usr/local/bin/uwsgi'
localconf_tmpl_path='/usr/local/etc/rattic/local.tmpl.cfg'
localconf_path='/srv/rattic/conf/local.cfg'

install -Zm 0600 "$localconf_tmpl_path" "$localconf_path"

function escape_sed {
  echo "$1" | sed -r 's/\//\\\//g'
}

sed -ir \
  's/{{\s*timezone\s*}}/'"$(escape_sed "$timezone")"'/g' \
  "$localconf_path"

sed -ir \
  's/{{\s*secretkey\s*}}/'"$(escape_sed "$secretkey")"'/g' \
  "$localconf_path"

sed -ir \
  's/{{\s*hostname\s*}}/'"$(escape_sed "$hostname")"'/g' \
  "$localconf_path"

sed -ir \
  's/{{\s*database_host\s*}}/'"$(escape_sed "$database_host")"'/g' \
  "$localconf_path"

sed -ir \
  's/{{\s*database_port\s*}}/'"$(escape_sed "$database_port")"'/g' \
  "$localconf_path"

sed -ir \
  's/{{\s*database_user\s*}}/'"$(escape_sed "$database_user")"'/g' \
  "$localconf_path"

sed -ir \
  's/{{\s*database_password\s*}}/'"$(escape_sed "$database_password")"'/g' \
  "$localconf_path"

rm -f "${localconf_path}r"

if [[ -n "$EMAIL_HOST" && -n "$EMAIL_USER" && -n "$EMAIL_PASSWORD" ]]; then
  if [[ ! "$EMAIL_PORT" =~ ^[0-9]+$ ]]; then
    EMAIL_PORT=587
  fi
  if [[ "$EMAIL_USETLS" != 'true' && "$EMAIL_USETLS" != 'false' ]]; then
    EMAIL_USETLS='true'
  fi
  if [[ -z "$EMAIL_FROM" ]]; then
    EMAIL_FROM="$EMAIL_USER"
  fi

  cat >> "$localconf_path" <<EOF

[email]
backend = django.core.mail.backends.smtp.EmailBackend
host = $EMAIL_HOST
port = $EMAIL_PORT
usetls = $EMAIL_USETLS
user = $EMAIL_USER
password = $EMAIL_PASSWORD
from_email = $EMAIL_FROM
EOF
fi

if [[ -n "$LDAP_DOMAIN" && -n "$LDAP_USER" && -n "$LDAP_PASS" && -n "$LDAP_USER_BASE" && -n "$LDAP_USER_FILTER" ]]; then
  if [[ -z "$LDAP_LOG" ]]; then
    LDAP_TYPE="DEBUG"
  fi
  if [[ -z "$LDAP_GROUP_BASE" ]]; then
    LDAP_GROUP_BASE="$LDAP_USER_BASE"
  fi
  if [[ -z "$LDAP_TYPE" ]]; then
    LDAP_TYPE="ActiveDirectoryGroupType"
  fi
  if [[ -z "$LDAP_GROUP_FILTER" ]]; then
    LDAP_GROUP_FILTER="(objectClass=group)"
  fi
  if [[ -z "$LDAP_STAFF" ]]; then
    LDAP_STAFF="$LDAP_GROUP_BASE"
  fi

  cat >> "$localconf_path" <<EOF

[ldap]
loglevel = $LDAP_LOG
uri = ldap://$LDAP_DOMAIN

binddn = $LDAP_USER
bindpw = $LDAP_PASS

userbase = $LDAP_USER_BASE
userfilter = $LDAP_USER_FILTER

groupbase = $LDAP_GROUP_BASE
groupfilter = $LDAP_GROUP_FILTER
grouptype = $LDAP_TYPE
staff = $LDAP_STAFF
EOF
fi

if [[ "$1" == 'migrate' ]]; then
  sleep 10
  $python manage.py migrate --all
fi

if [[ "$1" == 'init' ]]; then
  sleep 10
  $python manage.py syncdb --noinput
  $python manage.py demosetup
fi

$python manage.py collectstatic --noinput
$python manage.py compilemessages

if [[ "$1" != 'init' ]]; then
  exec $uwsgi --ini '/usr/local/etc/rattic/uwsgi.ini'
fi

set +e
