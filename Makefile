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
setup: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bin/setup'
	$(MAKE) mysql/drop_db
	$(MAKE) mysql/create_db
	$(DOCKER_COMPOSE) exec ruby bash -c './scripts/migrate.sh'
setup_for_ci:
	mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
	./scripts/migrate.sh
mysql/create_db:
	@$(DOCKER_COMPOSE) exec mysql mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql/drop_db:
	@$(DOCKER_COMPOSE) exec mysql mysql -u ${DB_USERNAME} -p${DB_PASSWORD} -e "DROP DATABASE IF EXISTS ${DB_NAME}"
ruby/bash:
	$(DOCKER_COMPOSE) exec ruby bash
ruby/rspec: up
	$(DOCKER_COMPOSE) exec ruby bash -c 'bundle exec rspec'