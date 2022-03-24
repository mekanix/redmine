REGGAE_PATH = /usr/local/share/reggae
FQDN ?= example.com
USE = letsencrypt ldap postgresql nginx
SERVICES += redmine https://github.com/mekanix/jail-redmine
.include <${REGGAE_PATH}/mk/use.mk>

post_setup:
.for service url in ${ALL_SERVICES}
	@echo "FQDN = ${FQDN}" >>services/${service}/project.mk
.endfor
	@echo "/usr/cbsd/jails-data/letsencrypt-data/usr/local/etc/dehydrated/certs /etc/certs nullfs rw 0 0" >services/ldap/templates/fstab
	@echo "/usr/cbsd/jails-data/letsencrypt-data/usr/local/etc/dehydrated/certs /etc/certs nullfs rw 0 0" >services/nginx/templates/fstab

.include <${REGGAE_PATH}/mk/project.mk>
