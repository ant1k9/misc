BACKUP_NAME=links.sqlite3.$(shell date +'%Y-%m-%dT%H-%M-%S').zip
BACKUP_FILE=/tmp/${BACKUP_NAME}

LINKS_FILE=/tmp/links.download
LINKS_DB=links.sqlite3

.PHONY: backup
backup:
	@zip ${BACKUP_FILE} ${LINKS_DB} &> /dev/null
	@echo ${BACKUP_FILE}

db:
	@[[ -f ${LINKS_DB} ]] || cat schema.sql | sqlite3 ${LINKS_DB}

load:
	@$(foreach file,$(shell ls commands/*cmd), LINKS_FILE=${LINKS_FILE} $(file) && ./load.fish ${LINKS_FILE};)
