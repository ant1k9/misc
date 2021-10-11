BACKUP_NAME=links.sqlite3.$(shell date +'%Y-%m-%dT%H-%M-%S').zip
BACKUP_FILE=/tmp/${BACKUP_NAME}

.PHONY: backup
backup:
	@zip ${BACKUP_FILE} links.sqlite3 &> /dev/null
	@echo ${BACKUP_FILE}
