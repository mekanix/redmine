.if exists(vars.mk)
.include <vars.mk>
.endif

.include <include.mk>


all: fetch setup
.if defined(jail)
	@echo "=== ${jail} ==="
	@${MAKE} ${MAKEFLAGS} -C projects/${jail}
.else
	@echo "=== postgresql ==="
	@${MAKE} ${MAKEFLAGS} -C projects/postgresql
	@echo
	@echo "=== redmine ==="
	@${MAKE} ${MAKEFLAGS} -C projects/redmine
	@echo
	@echo "=== web ==="
	@${MAKE} ${MAKEFLAGS} -C projects/web
	@echo
	@echo "=== configure ==="
	@${MAKE} ${MAKEFLAGS} -C projects/redmine web
.endif

init:
.if !exists(projects)
	@mkdir projects
.endif

fetch:
	@${MAKE} ${MAKEFLAGS} SUBPROJECT=postgresql fetch_subproject
	@${MAKE} ${MAKEFLAGS} SUBPROJECT=redmine fetch_subproject
	@${MAKE} ${MAKEFLAGS} SUBPROJECT=web fetch_subproject

fetch_subproject: init
.if !exists(projects/${SUBPROJECT})
	git clone https://github.com/mekanix/jail-${SUBPROJECT} projects/${SUBPROJECT}
.endif

setup: credentials
	@${MAKE} ${MAKEFLAGS} SUBPROJECT=postgresql setup_subproject
	@${MAKE} ${MAKEFLAGS} SUBPROJECT=redmine setup_subproject
	@${MAKE} ${MAKEFLAGS} SUBPROJECT=web setup_subproject

setup_subproject: fetch
	@rm -f projects/${SUBPROJECT}/vars.mk
	@echo ".if !defined(STAGE)" >>projects/${SUBPROJECT}/vars.mk
	@echo "STAGE=${STAGE}" >>projects/${SUBPROJECT}/vars.mk
	@echo ".endif" >>projects/${SUBPROJECT}/vars.mk
	@echo "" >>projects/${SUBPROJECT}/vars.mk
	@echo ".if !defined(DOMAIN)" >>projects/${SUBPROJECT}/vars.mk
	@echo "DOMAIN=${DOMAIN}" >>projects/${SUBPROJECT}/vars.mk
	@echo ".endif" >>projects/${SUBPROJECT}/vars.mk
	@echo "" >>projects/${SUBPROJECT}/vars.mk
	@echo ".if !defined(UID)" >>projects/${SUBPROJECT}/vars.mk
	@echo "UID=${UID}" >>projects/${SUBPROJECT}/vars.mk
	@echo ".endif" >>projects/${SUBPROJECT}/vars.mk
	@echo "" >>projects/${SUBPROJECT}/vars.mk
	@echo ".if !defined(GID)" >>projects/${SUBPROJECT}/vars.mk
	@echo "GID=${GID}" >>projects/${SUBPROJECT}/vars.mk
	@echo ".endif" >>projects/${SUBPROJECT}/vars.mk
	@echo "" >>projects/${SUBPROJECT}/vars.mk

destroy: down
.if defined(jail)
	@${MAKE} ${MAKEFLAGS} -C projects/${jail} destroy
.else
	@${MAKE} ${MAKEFLAGS} -C projects/postgresql destroy
	@${MAKE} ${MAKEFLAGS} -C projects/redmine destroy
	@${MAKE} ${MAKEFLAGS} -C projects/web destroy
.endif

login:
	@${MAKE} ${MAKEFLAGS} -C projects/${jail} login

down: setup
.if defined(jail)
	@${MAKE} ${MAKEFLAGS} -C projects/${jail} down
.else
	@${MAKE} ${MAKEFLAGS} -C projects/postgresql down
	@${MAKE} ${MAKEFLAGS} -C projects/redmine down
	@${MAKE} ${MAKEFLAGS} -C projects/web down
.endif

credentials:
.if !exists(${REDMINE_GROUP_VAR_FILE})
	@echo -n 'Enter new DB password: '
	@sh -c 'stty -echo; read prompt; echo "stage: ${STAGE}" ; echo "redmine_db_password: $$prompt"' >${REDMINE_GROUP_VAR_FILE}
	@cp ${REDMINE_GROUP_VAR_FILE} ${DB_GROUP_VAR_FILE}
	@echo
.endif
