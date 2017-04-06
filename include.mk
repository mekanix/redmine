.if !defined(DOMAIN)
DOMAIN=redmine.example.com
.endif

.if !defined(STAGE)
STAGE=prod
.endif

.if !defined(UID)
UID=1001
.endif

.if !defined(GID)
GID=1001
.endif

.if !defined(REDMINE_GROUP_VAR_FILE)
REDMINE_GROUP_VAR_FILE=projects/redmine/provision/group_vars/${STAGE}
.endif

.if !defined(DB_GROUP_VAR_FILE)
DB_GROUP_VAR_FILE=projects/redmine/provision/group_vars/db
.endif
