set -e

export HOME=/root
cd

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  gettext \
  libldap2-dev \
  libpq-dev \
  libsasl2-dev \
  libxml2-dev \
  libxslt-dev \
  python-pip \
  python2.7 \
  python2.7-dev \
  libmysqlclient-dev

curl -L 'https://github.com/tildaslash/RatticWeb/archive/v1.3.1.tar.gz' \
  -o rattic.tar.gz

mkdir -p /srv/rattic

tar -xvf "$HOME/rattic.tar.gz" \
  -C /srv/rattic \
  --strip-components 1

rm -fv "$HOME/rattic.tar.gz"

pip install -r /srv/rattic/requirements-mysql.txt
pip install jinja2 uwsgi mysql-python

apt-get purge -y \
  build-essential \
  ca-certificates \
  curl \
  libldap2-dev \
  libpq-dev \
  libsasl2-dev \
  libxml2-dev \
  libxslt-dev \
  python-pip

apt-get install -y --no-install-recommends \
  libldap-2.4 \
  libpq5 \
  libsasl2-2 \
  libxml2 \
  libxslt1.1

update-alternatives --install \
  /usr/bin/python python /usr/bin/python2.7 1

apt-get autoremove -y
apt-get clean -y
rm -rvf /var/lib/apt/lists/*
rm -rvf /var/tmp/*
rm -rvf /tmp/*

set +e
