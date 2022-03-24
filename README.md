# Redmine in FreeBSD jail

First, setup letsencrypt

```
echo 'FQDN = mydomain.com' >>vars.mk
make service=letsencrypt
make service=letsencrypt login
```

Edit `/usr/local/etc/letsencrypt_domains.txt`. You'll already have an example as
Ansible will create that file only if it doesn't exist and populate it with
fake data.

```
letsencrypt_update.sh
logout
make service=ldap
```

LDAP data based on `services/ldap/examples`.

```
sudo cp -r services/ldap/examples /usr/cbsd/jails-data/ldap-data/root/ldap
make login service=ldap
sed -e 's/DOMAIN/mydomain.com/g' ldap/domain.ldif >mydomain.com.ldif
sed -e 's/DOMAIN/mydomain.com/g' -e 's/USER/beastie/g' -e 's/FIRST/Bea/g' -e 's/LAST/Stie/g' ldap/user.ldif >beastie@mydomain.com.ldif
ldapadd -W -D cn=root,dc=ldap -f ldap/top.ldif
ldapadd -W -D cn=root,dc=ldap -f mydomain.com.ldif
ldapadd -W -D cn=root,dc=ldap -f beastie@mydomain.com.ldif
ldappasswd -W -D cn=root,dc=ldap uid=beastie,ou=mydomain.com,dc=account,dc=ldap
```

Setup PostgreSQL

```
make service=postgresql
make service=postgresql login
su - postgres
psql
CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'redmine' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;
```

Let Reggae setup everything else by running `make` and then setup nginx for
redmine based on redmine.conf example in nginx service. To setup redmine some
configuration has to be entered on the WEB interface, so go to redmine.<domain>
and login as `admin/admin`. After changing default password go to
`Administration / LDAP authentication` and click on `New authentication mode`.
Enter the following:

- name: ldap
- host: ldap
- port: 636 LDAPS (without certificate check)
- Base DN: dc=account,dc=ldap
- LDAP filter: objectClass=person
- On-the-fly user creation: yes
- Login attribute: mail
- Firstname attribute: cn
- Lastname attribute: sn
- Email attribute: mail

Leave other fields with their default value. Users will login with their
`email / password` from LDAP. On first login they will have to
