.PHONY: gen up
VARIANT=mariadb

MARIADB_FILE=mariadb-prod
PG_FILE=pg-prod
MARIADB_WEB_FILE=mariadb-prod-web
PG_WEB_FILE=pg-prod-web

MARIADB_PROJ=${MARIADB_FILE}
PG_PROJ=${PG_FILE}

SRC=./src/

GEN_DIR=./gen/

ENV_FILE=${SRC}/.env

# environment variables passed through the shell and unset env variables have higher precedence over the ones in the .env file

gen:
	$(eval $(call get_gen_manifest_path,__MANIFEST_PATH__,$(VARIANT)))
	if [ "$(VARIANT)" == "mariadb" ]; then \
	  ${MAKE} gen_mariadb_prod __MANIFEST_PATH__=$(__MANIFEST_PATH__); \
	elif [ "$(VARIANT)" == "pg" ]; then \
	  ${MAKE} gen_pg_prod __MANIFEST_PATH__=$(__MANIFEST_PATH__); \
	elif [ "$(VARIANT)" == "mariadb_web" ]; then \
	  ${MAKE} gen_mariadb_web_prod __MANIFEST_PATH__=$(__MANIFEST_PATH__); \
	elif [ "$(VARIANT)" == "pg_web" ]; then \
	  ${MAKE} gen_pg_web_prod __MANIFEST_PATH__=$(__MANIFEST_PATH__); \
	else \
	  @echo "Unexpected Variant"; \
	fi;

up:
	if   [ "$(AUTO_UPDATE)" == "true" ]; then \
	  ${MAKE} gen VARIANT=$(VARIANT); \
	fi;
	$(eval $(call get_gen_manifest_path,__MANIFEST_PATH__,$(VARIANT)))
	${MAKE} _up __MANIFEST_PATH__=$(__MANIFEST_PATH__)

down:
	if   [ "$(AUTO_UPDATE)" == "true" ]; then \
	  ${MAKE} gen VARIANT=$(VARIANT); \
	fi;
	$(eval $(call get_gen_manifest_path,__MANIFEST_PATH__,$(VARIANT)))
	${MAKE} _down __MANIFEST_PATH__=$(__MANIFEST_PATH__)

#############
## Helpers ##
#############

gen_mariadb_prod: setup
	docker-compose \
	  --env-file=${ENV_FILE} \
	  -p ${MARIADB_PROJ} \
	  -f ${SRC}/common.yml \
	  -f ${SRC}/db.mariadb.yml \
	  -f ${SRC}/web.db.claim.yml \
	  -f ${SRC}/web.yml \
	  -f ${SRC}/web.mariadb.yml \
	  config \
	> ${__MANIFEST_PATH__}

gen_pg_prod: setup
	docker-compose \
	  --env-file=${ENV_FILE} \
	  -p ${PG_PROJ} \
	  -f ${SRC}/common.yml \
	  -f ${SRC}/db.pg.yml \
	  -f ${SRC}/web.db.claim.yml \
	  -f ${SRC}/web.yml \
	  -f ${SRC}/web.pg.yml \
	  config \
	> ${__MANIFEST_PATH__}

gen_mariadb_web_prod: setup
	docker-compose \
	  --env-file=${ENV_FILE} \
	  -p ${MARIADB_PROJ} \
	  -f ${SRC}/common.yml \
	  -f ${SRC}/web.yml \
	  -f ${SRC}/web.mariadb.yml \
	  config \
	> ${__MANIFEST_PATH__}

gen_pg_web_prod: setup
	docker-compose \
	  --env-file=${ENV_FILE} \
	  -p ${PG_PROJ} \
	  -f ${SRC}/common.yml \
	  -f ${SRC}/web.yml \
	  -f ${SRC}/web.pg.yml \
	  config \
	> ${__MANIFEST_PATH__}

setup:
	mkdir -p ${GEN_DIR}

define get_gen_manifest_path
path=$(shell
    if   [ "$(2)" == "mariadb" ];     then \
      echo ${GEN_DIR}/${MARIADB_FILE}.yml; \
    elif [ "$(2)" == "pg" ];          then \
	  echo ${GEN_DIR}/${PG_FILE}.yml; \
    elif [ "$(2)" == "mariadb_web" ]; then \
	  echo ${GEN_DIR}/${MARIADB_WEB_FILE}.yml; \
    elif [ "$(2)" == "pg_web" ];      then \
	  echo ${GEN_DIR}/${PG_WEB_FILE}.yml; \
    else \
	  echo ${GEN_DIR}/${PG_FILE}.yml; \
	fi;)

$(1) := $$(path)
endef

_up:
	docker-compose -f ${__MANIFEST_PATH__} --env-file=${ENV_FILE} up -d

_down:
	docker-compose -f ${__MANIFEST_PATH__} --env-file=${ENV_FILE} down

### INTERFACE
# make gen VARIANT=mariadb
# make up VARIANT=mariadb AUTO_UPDATE=true
# make down VARIANT=mariadb AUTO_UPDATE=false
# make up VARIANT=mariadb_web AUTO_UPDATE=true
# make down VARIANT=mariadb_web AUTO_UPDATE=true


