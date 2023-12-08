include .env.test
DOCKER_COMPOSE = docker compose --env-file .env.test

build:
	$(DOCKER_COMPOSE) build
up:
	$(DOCKER_COMPOSE) up -d
down:
	$(DOCKER_COMPOSE) stop
restart:
	$(MAKE) down
	$(MAKE) up
ps:
	$(DOCKER_COMPOSE) ps
bash:
	$(DOCKER_COMPOSE) exec ruby bash
setup: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bin/setup'
	$(MAKE) drop_db
	$(MAKE) create_db
	$(DOCKER_COMPOSE) exec ruby bash -c './scripts/migrate.sh'
create_db:
	@$(DOCKER_COMPOSE) exec mysql mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
drop_db:
	@$(DOCKER_COMPOSE) exec mysql mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "DROP DATABASE IF EXISTS ${DB_NAME}"
