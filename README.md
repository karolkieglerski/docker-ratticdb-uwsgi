# kilerkarol/ratticdb-uwsgi

## Usage normal

```shell
docker run \
  --name 'ratticdb-uwsgi' \
  --link 'ratticdb-postgresql:postgres' \
  -e 'TIMEZONE=UTC' \
  -e 'VIRTUAL_HOST=somedomain.example.com' \
  -e 'SECRETKEY=someverysecretkeyforsessions' \
  kilerkarol/ratticdb-uwsgi:1.3
```
## add email

```shell
'EMAIL_HOST=smtp.example.com'
'EMAIL_PORT=587'
'EMAIL_USER=example@example.com'
'EMAIL_PASSWORD=someemailpassword'
'EMAIL_FROM=emailed-from@example.com'
```

## add LDAP

```shell
'LDAP_DOMAIN=test.testdomain.com'
'LDAP_USER=ratticdomainuser@test.testdomain.com'
'LDAP_PASS=bindingpass'
'LDAP_USER_BASE=OU=Users,DC=test,DC=testdomain,DC=com'
'LDAP_USER_FILTER=(&(objectClass=user)(memberOf=CN=Rattic_Users,OU=Groups,DC=test,DC=testdomain,DC=com))'
```
