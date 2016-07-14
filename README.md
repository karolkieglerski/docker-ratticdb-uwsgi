# kilerkarol/ratticdb-uwsgi

## Usage

```shell
docker run \
  --name 'ratticdb-uwsgi' \
  --link 'ratticdb-postgresql:postgres' \
  -e 'TIMEZONE=UTC' \
  -e 'VIRTUAL_HOST=somedomain.example.com' \
  -e 'SECRETKEY=someverysecretkeyforsessions' \
  -e 'EMAIL_HOST=smtp.example.com' \
  -e 'EMAIL_PORT=587' \
  -e 'EMAIL_USER=example@example.com' \
  -e 'EMAIL_PASSWORD=someemailpassword' \
  -e 'EMAIL_FROM=emailed-from@example.com' \
  kilerkarol/ratticdb-uwsgi:1.3
```
