REGGAE_PATH = /usr/local/share/reggae
USE = letsencrypt nginx
SERVICES += redmine https://github.com/mekanix/jail-redmine

.include <${REGGAE_PATH}/mk/project.mk>
